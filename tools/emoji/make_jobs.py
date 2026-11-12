#!/usr/bin/env python3
"""Writes the prompt list for one L40S batch (docs/EMOJI_SET_PLAN.md §9–10).

  python3 make_jobs.py I0                    # style test: 8 emoji × every style × 2 seeds
  python3 make_jobs.py I1                    # pilot: 2 emoji per category
  python3 make_jobs.py I2                    # the rest of the set
  python3 make_jobs.py I3 --ids a,b --from-k 4 --count 6   # retries

Output: tools/emoji/jobs/<batch>.json, a list of
{file, id, style, seed, size, prompt, negative}. `file` is the name the
draft PNG gets (<id>__<style>__<seed>.png). I1–I3 need styles.json
`selected`."""
import argparse
import json
import os

HERE = os.path.dirname(os.path.abspath(__file__))


def load(name):
    with open(os.path.join(HERE, name)) as f:
        return json.load(f)


def seeds(styles, item, ks):
    s = styles['seed']
    return [s['base'] + s['per_item'] * item['n'] + k for k in ks]


def default_ks(item):
    return range(8 if item['category'] == 'hands' else 4)


def job(styles, item, style, seed):
    prompt = f'{styles["styles"][style]}, {item["subject"]}, {styles["framing"]}'
    return {'file': f'{item["id"]}__{style}__{seed}.png', 'id': item['id'], 'style': style,
            'seed': seed, 'size': styles['size'], 'prompt': prompt, 'negative': styles['negative']}


def pilot_ids(data, exclude):
    picked = []
    for c in data['categories']:
        items = [e for e in data['emoji']
                 if e['category'] == c['id'] and not e.get('reserve') and e['id'] not in exclude]
        picked += [items[0]['id'], items[len(items) // 2]['id']]
    return picked


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('batch', choices=['I0', 'I1', 'I2', 'I3'])
    ap.add_argument('--ids', help='comma-separated ids (I3)')
    ap.add_argument('--from-k', type=int, default=0)
    ap.add_argument('--count', type=int, default=6)
    a = ap.parse_args()

    data, styles = load('emoji_set.json'), load('styles.json')
    by_id = {e['id']: e for e in data['emoji']}
    test = styles['style_test']
    jobs = []
    if a.batch == 'I0':
        for id_ in test['ids']:
            for style in styles['styles']:
                for seed in seeds(styles, by_id[id_], range(test['seeds_per_item'])):
                    jobs.append(job(styles, by_id[id_], style, seed))
    else:
        style = styles['selected']
        if not style:
            raise SystemExit('styles.json has no selected style yet (decision B1)')
        pilot = pilot_ids(data, set(test['ids']))
        if a.batch == 'I1':
            ids, ks = pilot, None
        elif a.batch == 'I2':
            done = set(pilot)
            ids, ks = [e['id'] for e in data['emoji'] if e['id'] not in done], None
        else:
            if not a.ids:
                raise SystemExit('I3 needs --ids')
            ids, ks = a.ids.split(','), range(a.from_k, a.from_k + a.count)
        for id_ in ids:
            item = by_id[id_]
            for seed in seeds(styles, item, ks or default_ks(item)):
                jobs.append(job(styles, item, style, seed))

    os.makedirs(os.path.join(HERE, 'jobs'), exist_ok=True)
    path = os.path.join(HERE, 'jobs', f'{a.batch}.json')
    with open(path, 'w') as f:
        json.dump(jobs, f, ensure_ascii=False, indent=1)
        f.write('\n')
    print(f'{len(jobs)} images → {os.path.relpath(path, HERE)} (~{len(jobs) * 21 / 60:.0f} min at 21 s)')


if __name__ == '__main__':
    main()
