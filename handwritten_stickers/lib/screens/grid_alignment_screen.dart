import 'dart:io';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../services/perspective_transformer.dart';
import '../widgets/grid_painter.dart';

/// Interactive screen for aligning a grid overlay on a photo of the
/// handwriting template, then exporting a perspective-corrected image.
class GridAlignmentScreen extends StatefulWidget {
  const GridAlignmentScreen({super.key});

  @override
  State<GridAlignmentScreen> createState() => _GridAlignmentScreenState();
}

class _GridAlignmentScreenState extends State<GridAlignmentScreen> {
  ui.Image? _image;
  String? _imagePath;
  bool _isProcessing = false;
  bool _showGrid = true;

  /// Grid corner positions in image-pixel coordinates.
  /// Order: topLeft, topRight, bottomRight, bottomLeft.
  List<Offset> _corners = [];

  /// Index of the corner currently being dragged, or -1.
  int _draggingCorner = -1;

  final TransformationController _transformController =
      TransformationController();

  /// Key for the InteractiveViewer to get its RenderBox.
  final GlobalKey _viewerKey = GlobalKey();

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  /// Initialize corners at a reasonable default position.
  void _initCorners() {
    if (_image == null) return;
    final w = _image!.width.toDouble();
    final h = _image!.height.toDouble();
    final insetX = w * 0.08;
    final insetY = h * 0.05;
    _corners = [
      Offset(insetX, insetY),
      Offset(w - insetX, insetY),
      Offset(w - insetX, h - insetY),
      Offset(insetX, h - insetY),
    ];
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result == null || result.files.single.path == null) return;

    final path = result.files.single.path!;
    final bytes = await File(path).readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();

    setState(() {
      _image = frame.image;
      _imagePath = path;
      _initCorners();
    });
  }

  Future<void> _exportAligned() async {
    if (_image == null || _corners.length != 4) return;

    setState(() => _isProcessing = true);

    try {
      final pngBytes = await PerspectiveTransformer.transform(
        sourceImage: _image!,
        corners: _corners,
      );

      final baseName = _imagePath != null
          ? _imagePath!.split('/').last.replaceAll(RegExp(r'\.[^.]+$'), '')
          : 'aligned';
      final fileName = '${baseName}_aligned.png';

      final savePath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Aligned Image',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['png'],
        bytes: pngBytes,
      );

      if (savePath != null && mounted) {
        final file =
            File(savePath.endsWith('.png') ? savePath : '$savePath.png');
        if (!await file.exists()) {
          await file.writeAsBytes(pngBytes);
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Saved: ${file.path}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  // ─── coordinate helpers ────────────────────────────────────────────

  /// Convert a local widget-space point to image-pixel coordinates by
  /// inverting the InteractiveViewer + FittedBox transformation.
  Offset? _localToImage(Offset localPoint) {
    if (_image == null) return null;
    final viewerBox =
        _viewerKey.currentContext?.findRenderObject() as RenderBox?;
    if (viewerBox == null) return null;

    // 1. Undo InteractiveViewer transform
    final matrix = _transformController.value;
    final inverted = Matrix4.inverted(matrix);
    final afterViewer = MatrixUtils.transformPoint(inverted, localPoint);

    // 2. Undo FittedBox scaling: widget size → image size
    final viewerSize = viewerBox.size;
    final imgW = _image!.width.toDouble();
    final imgH = _image!.height.toDouble();
    final fittedScale = _fittedBoxScale(viewerSize, Size(imgW, imgH));
    final fittedW = imgW * fittedScale;
    final fittedH = imgH * fittedScale;
    // FittedBox centers the content
    final offsetX = (viewerSize.width - fittedW) / 2;
    final offsetY = (viewerSize.height - fittedH) / 2;

    final imageX = (afterViewer.dx - offsetX) / fittedScale;
    final imageY = (afterViewer.dy - offsetY) / fittedScale;
    return Offset(imageX, imageY);
  }

  double _fittedBoxScale(Size parent, Size child) {
    return (parent.width / child.width) < (parent.height / child.height)
        ? parent.width / child.width
        : parent.height / child.height;
  }

  /// Find which corner is near the given image-space point.
  int _hitTestCorner(Offset imagePoint) {
    final scale = _transformController.value.getMaxScaleOnAxis();
    // Bigger hit target when zoomed out, smaller when zoomed in
    final hitRadius = 40.0 / scale;

    double bestDist = double.infinity;
    int bestIndex = -1;
    for (int i = 0; i < _corners.length; i++) {
      final dist = (_corners[i] - imagePoint).distance;
      if (dist < hitRadius && dist < bestDist) {
        bestDist = dist;
        bestIndex = i;
      }
    }
    return bestIndex;
  }

  // ─── build ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_imagePath != null
            ? 'Grid Alignment \u2014 ${_imagePath!.split('/').last}'
            : 'Grid Alignment'),
        actions: [
          if (_image != null) ...[
            IconButton(
              icon: const Icon(Icons.folder_open),
              onPressed: _pickImage,
              tooltip: 'Open Another Image',
            ),
            IconButton(
              icon: Icon(_showGrid ? Icons.grid_on : Icons.grid_off),
              onPressed: () => setState(() => _showGrid = !_showGrid),
              tooltip: _showGrid ? 'Hide Grid' : 'Show Grid',
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => setState(() => _initCorners()),
              tooltip: 'Reset Grid',
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: _isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_circle),
              onPressed: _isProcessing ? null : _exportAligned,
              tooltip: 'Export Aligned Image',
            ),
          ],
        ],
      ),
      body: _image == null ? _buildEmptyState() : _buildEditor(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_library_outlined,
              size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Open a photo of your handwriting template',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.folder_open),
            label: const Text('Open Image'),
          ),
          const SizedBox(height: 12),
          Text(
            'Drag the 4 corners to align the grid on the photo,\n'
            'then export the perspective-corrected image.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildEditor() {
    // Use Listener for raw pointer events so we can decide whether to
    // intercept (corner drag) or pass through (pan/zoom) BEFORE Flutter's
    // gesture arena resolves.
    return Listener(
      onPointerDown: (event) {
        final imagePoint = _localToImage(event.localPosition);
        if (imagePoint == null) return;
        final hit = _hitTestCorner(imagePoint);
        if (hit >= 0) {
          setState(() => _draggingCorner = hit);
        }
      },
      onPointerMove: (event) {
        if (_draggingCorner < 0) return;
        final imagePoint = _localToImage(event.localPosition);
        if (imagePoint == null) return;
        setState(() {
          _corners = List.of(_corners);
          _corners[_draggingCorner] = imagePoint;
        });
      },
      onPointerUp: (_) {
        if (_draggingCorner >= 0) {
          setState(() => _draggingCorner = -1);
        }
      },
      child: InteractiveViewer(
        key: _viewerKey,
        transformationController: _transformController,
        minScale: 0.2,
        maxScale: 8.0,
        boundaryMargin: const EdgeInsets.all(300),
        // Disable pan when dragging a corner
        panEnabled: _draggingCorner < 0,
        scaleEnabled: _draggingCorner < 0,
        child: FittedBox(
          child: SizedBox(
            width: _image!.width.toDouble(),
            height: _image!.height.toDouble(),
            child: CustomPaint(
              painter: _ImageWithGridPainter(
                image: _image!,
                corners: _showGrid ? _corners : [],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Draws the background image and optionally the grid overlay in one pass.
class _ImageWithGridPainter extends CustomPainter {
  final ui.Image image;
  final List<Offset> corners;

  _ImageWithGridPainter({required this.image, required this.corners});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImage(image, Offset.zero, Paint());
    if (corners.length == 4) {
      GridPainter(corners: corners).paint(canvas, size);
    }
  }

  @override
  bool shouldRepaint(_ImageWithGridPainter oldDelegate) => true;
}
