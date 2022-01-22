import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:paint_redesigned/models/models.dart';

class CanvasWidget extends StatefulWidget {
  final CanvasController? canvasController;

  const CanvasWidget({Key? key, this.canvasController}) : super(key: key);

  @override
  _CanvasWidgetState createState() => _CanvasWidgetState();
}

class _CanvasWidgetState extends State<CanvasWidget> {
  @override
  void initState() {
    super.initState();
    if (widget.canvasController == null) {
      canvasController = CanvasController();
      canvasController.strokeWidthh = 5.0;
      canvasController.brushColor = Colors.black;
      canvasController.backgroundColor = Colors.grey[100]!;
    } else {
      canvasController = widget.canvasController!;
    }
  }

  void _onStart(DragStartDetails startDetails) {
    final renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(startDetails.globalPosition);
    canvasController._pathHistory.add(localPosition);
    canvasController._notifyListeners();
  }

  void _onUpdateDetails(DragUpdateDetails updateDetails) {
    final renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(updateDetails.globalPosition);
    canvasController._pathHistory.updateCurrent(localPosition);
    canvasController._notifyListeners();
  }

  void onEnd(DragEndDetails downDetails) {
    canvasController._notifyListeners();
  }

  late CanvasController canvasController;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onPanStart: (startDetails) => _onStart(startDetails),
        onPanUpdate: (updateDetails) => _onUpdateDetails(updateDetails),
        onPanEnd: (downDetails) => onEnd(downDetails),
        child: CustomPaint(
          willChange: true,
          painter: CanvasPainter(canvasController._pathHistory,
              painterModel: canvasController),
          child: Container(),
        ));
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class CanvasController extends ChangeNotifier {
  Color _color = Colors.black;

  Color _backgroundColor = Colors.white;

  double _strokeWidth = 4.0;

  bool _isEraseMode = false;

  ui.Image? _image;

  ui.Image? get image => _image;

  set image(ui.Image? value) {
    _image = value;
    _background = CanvasBackground.image;
    _updatePaint();
    notifyListeners();
  }

  final _PathHistory _pathHistory = _PathHistory();

  bool get isEmpty => _pathHistory.isPathsEmpty;

  List<MapEntry<Path, Paint>> get paths => _pathHistory.paths;

  Color get brushColor => _color;

  bool get isEraseMode => _isEraseMode;

  bool get isUndoEmpty => _pathHistory.isUndoEmpty;

  CanvasBackground _background = CanvasBackground.plain;

  CanvasBackground get background => _background;

  set background(CanvasBackground value) {
    if (value != CanvasBackground.image && _image != null) {
      _image = null;
    }
    print('background change $value');
    _background = value;
    _updatePaint();
    notifyListeners();
  }

  set isEraseMode(bool value) {
    _isEraseMode = value;
    _updatePaint();
    notifyListeners();
  }

  set brushColor(Color color) {
    _color = color;
    _updatePaint();
  }

  Color get backgroundColor => _backgroundColor;

  set backgroundColor(Color color) {
    _backgroundColor = color;
    _updatePaint();
  }

  double get strokeWidthh => _strokeWidth;

  set strokeWidthh(double thickness) {
    _strokeWidth = thickness;
    _updatePaint();
  }

  void _updatePaint() {
    Paint paint = Paint();
    if (_isEraseMode) {
      paint.blendMode = BlendMode.clear;
    } else {
      paint.blendMode = BlendMode.srcOver;
    }
    paint.color = brushColor;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = strokeWidthh;

    Paint backGroundPaint = Paint();
    backGroundPaint.blendMode = BlendMode.dstOver;
    backGroundPaint.color = backgroundColor;

    _pathHistory._paint = paint;
    _pathHistory._backgroundPaint = backGroundPaint;
    if (image != null) {
      _pathHistory.image = image;
    }
    _pathHistory.background = background;
    notifyListeners();
  }

  void undo() {
    if (isEmpty) return;
    _pathHistory.undo();
    notifyListeners();
  }

  void redo() {
    if (isUndoEmpty) return;
    _pathHistory.redo();
    notifyListeners();
  }

  void _notifyListeners() {
    notifyListeners();
  }

  void clear() {
    _pathHistory.clear();
    notifyListeners();
  }
}

class CanvasPainter extends CustomPainter {
  final _PathHistory _path;

  /// if the model updates paint will repaint
  CanvasPainter(this._path, {Listenable? painterModel})
      : super(repaint: painterModel);

  @override
  void paint(Canvas canvas, Size size) {
    _path.draw(canvas, size);
  }

  @override
  bool shouldRepaint(CanvasPainter oldDelegate) => false;
}

class _PathHistory {
  final List<MapEntry<Path, Paint>> _paths;

  final List<MapEntry<Path, Paint>> _undoHistory;

  bool _isUndo = false;

  Paint _paint;

  Paint _backgroundPaint;

  CanvasBackground _background = CanvasBackground.plain;

  ui.Image? _image;

  ui.Image? get image => _image;

  set image(ui.Image? value) {
    _image = value;
    _background = CanvasBackground.image;
  }

  CanvasBackground get background => _background;

  set background(CanvasBackground value) {
    _background = value;
  }

  bool get isPathsEmpty => _paths.isEmpty;

  bool get isUndo => _isUndo;

  bool get isUndoEmpty => _undoHistory.isEmpty;

  set isUndo(bool value) {
    _isUndo = value;
  }

  List<MapEntry<Path, Paint>> get paths => _paths;

  _PathHistory()
      : _paths = <MapEntry<Path, Paint>>[],
        _undoHistory = <MapEntry<Path, Paint>>[],
        _backgroundPaint = Paint()
          ..blendMode = BlendMode.dstOver
          ..color = Colors.white,
        _paint = Paint()
          ..color = Colors.black
          ..strokeWidth = 1.0
          ..style = PaintingStyle.fill;

  void setBackgroundColor(Color backgroundColor) {
    _backgroundPaint.color = backgroundColor;
  }

  void undo() {
    final removed = _paths.removeLast();
    _undoHistory.add(removed);
    isUndo = true;
  }

  void redo() {
    _paths.add(_undoHistory.removeLast());
  }

  void clear() {
    _paths.clear();
  }

  void add(Offset startPoint) {
    Path path = Path();
    path.moveTo(startPoint.dx, startPoint.dy);
    _paths.add(MapEntry<Path, Paint>(path, _paint));
    if (isUndo) {
      isUndo = false;
      _undoHistory.clear();
    }
  }

  void updateCurrent(Offset nextPoint) {
    Path path = _paths.last.key;
    path.lineTo(nextPoint.dx, nextPoint.dy);
  }

  void draw(Canvas canvas, Size size) {
    canvas.saveLayer(Offset.zero & size, Paint());
    // drawImage(canvas, size);

    for (MapEntry<Path, Paint> path in _paths) {
      Paint p = path.value;
      canvas.drawPath(path.key, p);
    }

    if (_background == CanvasBackground.grid) {
      drawGrid(canvas, size);
    } else if (background == CanvasBackground.dots) {
      drawDots(canvas, size);
    } else if (background == CanvasBackground.hlines) {
      drawHLines(canvas, size);
    } else if (background == CanvasBackground.vlines) {
      drawVlines(canvas, size);
    } else if (background == CanvasBackground.image) {
      drawImage(canvas, size);
    } else {
      /// Prevent drawing out of canvas
      canvas.drawRect(
          Rect.fromLTWH(0.0, 0.0, size.width, size.height), _backgroundPaint);
      drawNone(canvas, size);
    }
    canvas.restore();
  }

  void drawNone(Canvas canvas, Size size) {
    // do nothing
  }

  void drawImage(Canvas canvas, Size size) {
    if (image == null) return;
    canvas.drawImage(image!, Offset.zero, _backgroundPaint);

    /// TODO: Image is not fully painted
    // paintImage(
    //     canvas: canvas,
    //     rect: Rect.fromLTWH(0.0, 0.0, size.width, size.height),
    //     image: image!);
  }

  void drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    final width = size.width;
    final height = size.height;
    const count = 20;
    final step = max(size.height, size.width) / count;
    for (int i = 0; i <= count; i++) {
      final x = step * i;
      canvas.drawLine(Offset(x, 0.0), Offset(x, height), paint);
    }
    for (int i = 0; i <= count; i++) {
      final y = step * i;
      canvas.drawLine(Offset(0.0, y), Offset(width, y), paint);
    }
  }

  void drawDots(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.0
      ..style = PaintingStyle.fill;
    const countX = 20;
    const countY = 20;
    final step = max(size.width, size.height) / countX;
    for (int i = 0; i <= countX; i++) {
      final x = step * i;
      for (int j = 0; j <= countY; j++) {
        final y = step * j;
        canvas.drawCircle(Offset(x, y), 2.0, paint);
      }
    }
  }

  void drawHLines(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.0
      ..style = PaintingStyle.fill;
    final width = size.width;
    final height = size.height;
    const count = 20;
    final step = max(width, height) / count;
    for (int i = 0; i <= count; i++) {
      final y = step * i;
      canvas.drawLine(Offset(0.0, y), Offset(width, y), paint);
    }
  }

  void drawVlines(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.0
      ..style = PaintingStyle.fill;
    final width = size.width;
    final height = size.height;
    const count = 20;
    final step = max(width, height) / count;
    for (int i = 0; i <= count; i++) {
      final x = step * i;
      canvas.drawLine(Offset(x, 0.0), Offset(x, height), paint);
    }
  }
}
