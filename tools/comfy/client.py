#!/usr/bin/env python3
"""Shared ComfyUI HTTP client (plan 02, A7; used by tools/sheets and tools/emoji).

Standard library only. The server sits behind Cloudflare Access, so every
request carries the service-token headers from the environment:

    COMFY_URL                 default https://comfyui.ol1n.com
    CF_ACCESS_CLIENT_ID       Cloudflare Zero Trust service token id
    CF_ACCESS_CLIENT_SECRET   … and secret (never commit them)

Values may also live in tools/comfy/.env (see .env.example).

Workflows are JSON exported from the ComfyUI UI with *Save (API Format)*.
Scripts fill them by node title (`_meta.title`), see `set_inputs`.

CLI:
    python3 tools/comfy/client.py inventory [--out inventory.json]
"""
from __future__ import annotations

import argparse
import json
import mimetypes
import os
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
import uuid
from pathlib import Path

DEFAULT_URL = "https://comfyui.ol1n.com"
ENV_FILE = Path(__file__).with_name(".env")


def load_env(path: Path = ENV_FILE) -> None:
    """Minimal .env reader: KEY=VALUE lines, existing env vars win."""
    if not path.exists():
        return
    for line in path.read_text().splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        os.environ.setdefault(key.strip(), value.strip().strip('"').strip("'"))


class ComfyError(RuntimeError):
    pass


class ComfyClient:
    def __init__(self, url: str | None = None, retries: int = 3, timeout: float = 60):
        load_env()
        self.url = (url or os.environ.get("COMFY_URL") or DEFAULT_URL).rstrip("/")
        self.retries = retries
        self.timeout = timeout
        self.client_id = uuid.uuid4().hex
        self.headers = {"User-Agent": "handwritten-stickers/comfy-client"}
        cid = os.environ.get("CF_ACCESS_CLIENT_ID")
        secret = os.environ.get("CF_ACCESS_CLIENT_SECRET")
        if cid and secret:
            self.headers["CF-Access-Client-Id"] = cid
            self.headers["CF-Access-Client-Secret"] = secret

    # -- transport ---------------------------------------------------------

    def _request(self, method: str, path: str, body: bytes | None = None,
                 headers: dict | None = None, raw: bool = False):
        url = self.url + path
        h = dict(self.headers)
        h.update(headers or {})
        last: Exception | None = None
        for attempt in range(self.retries):
            req = urllib.request.Request(url, data=body, method=method, headers=h)
            try:
                with urllib.request.urlopen(req, timeout=self.timeout) as resp:
                    data = resp.read()
                    ctype = resp.headers.get("Content-Type", "")
                if raw:
                    return data
                if "text/html" in ctype and b"cloudflareaccess" in data.lower():
                    raise ComfyError("Cloudflare Access login page returned: set "
                                     "CF_ACCESS_CLIENT_ID / CF_ACCESS_CLIENT_SECRET")
                return json.loads(data) if data else None
            except urllib.error.HTTPError as e:
                detail = e.read()[:500].decode("utf-8", "replace")
                if e.code in (401, 403):
                    raise ComfyError(f"{method} {path}: HTTP {e.code} (Cloudflare Access token?) {detail}")
                if e.code < 500:
                    raise ComfyError(f"{method} {path}: HTTP {e.code} {detail}")
                last = ComfyError(f"{method} {path}: HTTP {e.code} {detail}")
            except (urllib.error.URLError, TimeoutError, ConnectionError) as e:
                last = e
            time.sleep(2 ** attempt)
        raise ComfyError(f"{method} {path} failed after {self.retries} attempts: {last}")

    def get(self, path: str, **params):
        if params:
            path += "?" + urllib.parse.urlencode(params)
        return self._request("GET", path)

    def post_json(self, path: str, payload) -> dict:
        return self._request("POST", path, json.dumps(payload).encode(),
                             {"Content-Type": "application/json"})

    # -- API ---------------------------------------------------------------

    def system_stats(self) -> dict:
        return self.get("/system_stats")

    def object_info(self) -> dict:
        return self.get("/object_info")

    def models(self, folder: str) -> list:
        try:
            return self.get(f"/models/{folder}") or []
        except ComfyError:
            return []

    def upload(self, path: str | Path, subfolder: str = "", overwrite: bool = True) -> str:
        """Uploads an image to the input folder; returns the name to put into LoadImage."""
        path = Path(path)
        boundary = uuid.uuid4().hex
        ctype = mimetypes.guess_type(path.name)[0] or "application/octet-stream"
        parts = []
        for name, value in (("overwrite", "true" if overwrite else "false"), ("subfolder", subfolder)):
            parts.append(f'--{boundary}\r\nContent-Disposition: form-data; name="{name}"\r\n\r\n{value}\r\n'.encode())
        parts.append(
            f'--{boundary}\r\nContent-Disposition: form-data; name="image"; filename="{path.name}"\r\n'
            f"Content-Type: {ctype}\r\n\r\n".encode() + path.read_bytes() + b"\r\n")
        parts.append(f"--{boundary}--\r\n".encode())
        res = self._request("POST", "/upload/image", b"".join(parts),
                            {"Content-Type": f"multipart/form-data; boundary={boundary}"})
        name = res["name"]
        return f"{res.get('subfolder')}/{name}" if res.get("subfolder") else name

    def queue(self, workflow: dict) -> str:
        res = self.post_json("/prompt", {"prompt": workflow, "client_id": self.client_id})
        if res.get("node_errors"):
            raise ComfyError(f"workflow rejected: {json.dumps(res['node_errors'])[:1000]}")
        return res["prompt_id"]

    def wait(self, prompt_id: str, timeout: float = 1800, poll: float = 2.0) -> dict:
        """Polls /history until the prompt finished; returns its history entry."""
        deadline = time.time() + timeout
        while time.time() < deadline:
            hist = self.get(f"/history/{prompt_id}") or {}
            entry = hist.get(prompt_id)
            if entry:
                status = entry.get("status", {})
                if status.get("status_str") == "error":
                    msgs = [m for m in status.get("messages", []) if m[0] == "execution_error"]
                    raise ComfyError(f"prompt {prompt_id} failed: {json.dumps(msgs)[:1000]}")
                if status.get("completed", True):
                    return entry
            time.sleep(poll)
        raise ComfyError(f"prompt {prompt_id} did not finish within {timeout:.0f} s")

    def download(self, entry: dict, out_dir: str | Path, prefix: str = "") -> list[Path]:
        """Downloads every output image of a history entry."""
        out_dir = Path(out_dir)
        out_dir.mkdir(parents=True, exist_ok=True)
        paths = []
        for node_out in entry.get("outputs", {}).values():
            for img in node_out.get("images", []):
                data = self._request("GET", "/view?" + urllib.parse.urlencode({
                    "filename": img["filename"], "subfolder": img.get("subfolder", ""),
                    "type": img.get("type", "output")}), raw=True)
                p = out_dir / f"{prefix}{img['filename']}"
                p.write_bytes(data)
                paths.append(p)
        return paths

    def run(self, workflow: dict, out_dir: str | Path, prefix: str = "", timeout: float = 1800) -> list[Path]:
        """queue + wait + download."""
        return self.download(self.wait(self.queue(workflow), timeout), out_dir, prefix)


# -- workflow helpers -------------------------------------------------------

def load_workflow(path: str | Path) -> dict:
    return json.loads(Path(path).read_text())


def node_by_title(workflow: dict, title: str) -> dict:
    for node in workflow.values():
        if node.get("_meta", {}).get("title") == title:
            return node
    raise KeyError(f"workflow has no node titled {title!r}")


def set_inputs(workflow: dict, values: dict[str, dict]) -> dict:
    """Returns a copy with inputs set by node title: {"Positive": {"text": "…"}}."""
    wf = json.loads(json.dumps(workflow))
    for title, inputs in values.items():
        node = node_by_title(wf, title)
        for key, value in inputs.items():
            if key not in node["inputs"]:
                raise KeyError(f"node {title!r} has no input {key!r}")
            node["inputs"][key] = value
    return wf


def inventory(client: ComfyClient) -> dict:
    """GPU, model folders and installed node types (for choosing workflows)."""
    stats = client.system_stats()
    info = client.object_info()
    folders = ["checkpoints", "diffusion_models", "loras", "controlnet", "clip_vision",
               "ipadapter", "upscale_models", "vae", "text_encoders", "clip"]
    return {
        "url": client.url,
        "devices": stats.get("devices", []),
        "system": stats.get("system", {}),
        "models": {f: client.models(f) for f in folders},
        "node_types": sorted(info.keys()),
    }


def main(argv=None) -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)
    inv = sub.add_parser("inventory", help="dump GPU, models and node types")
    inv.add_argument("--out", default="-")
    args = ap.parse_args(argv)
    if args.cmd == "inventory":
        data = json.dumps(inventory(ComfyClient()), indent=2, ensure_ascii=False)
        if args.out == "-":
            print(data)
        else:
            Path(args.out).write_text(data)
            print(f"inventory → {args.out}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
