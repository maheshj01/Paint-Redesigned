import 'package:flutter/material.dart';

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

  final _PathHistory _pathHistory = _PathHistory();

  bool get isEmpty => _pathHistory.isPathsEmpty;

  List<MapEntry<Path, Paint>>  get paths => _pathHistory.paths;

  Color get brushColor => _color;

  bool get isEraseMode => _isEraseMode;

  bool get isUndoEmpty => _pathHistory.isUndoEmpty;

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

  bool get isPathsEmpty => _paths.isEmpty;

  bool get isUndo => _isUndo;

  bool get isUndoEmpty => _undoHistory.isEmpty;

  set isUndo(bool value) {
    _isUndo = value;
  }

  List<MapEntry<Path, Paint>>  get paths => _paths;

  /// inittialize defaults
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
    for (MapEntry<Path, Paint> path in _paths) {
      Paint p = path.value;
      canvas.drawPath(path.key, p);
    }
    canvas.drawRect(
        Rect.fromLTWH(0.0, 0.0, size.width, size.height), _backgroundPaint);
    canvas.restore();
  }
}
