import 'package:flutter/services.dart';
import 'package:paint_redesigned/canvas.dart';
import 'package:paint_redesigned/widgets/tool_explorer.dart';
import 'package:flutter/material.dart';
import 'package:paint_redesigned/toolbar_view.dart';
import 'package:provider/provider.dart';
import 'constants/constants.dart';
import 'models/models.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CanvasNotifier>(create: (_) => CanvasNotifier()),
        ChangeNotifierProvider<BrushNotifier>(create: (_) => BrushNotifier()),
        ChangeNotifierProvider<ToolController>(create: (_) => ToolController()),
      ],
      child: MaterialApp(
          title: 'Flutter Canvas',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
              primarySwatch: Colors.blue,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              iconTheme: IconThemeData(color: defaultIconColor)),
          home: const PaintHome()),
    );
  }
}

class PaintHome extends StatefulWidget {
  const PaintHome({Key? key}) : super(key: key);

  @override
  _PaintHomeState createState() => _PaintHomeState();
}

class _PaintHomeState extends State<PaintHome> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: <Widget>[
          const Align(alignment: Alignment.centerRight, child: ToolExplorer()),
          Row(
            children: const [
              Expanded(child: CanvasBuilder()),
              SizedBox(
                width: explorerWidth,
              )
            ],
          ),
        ],
      ),
    );
  }
}

class UndoIntent extends Intent {
  UndoIntent({this.description, required this.action});

  /// undo the last action
  Function()? action;

  /// description about the action
  final String? description;
}

class RedoIntent extends Intent {
  RedoIntent({this.description, required this.action});

  /// undo the last action
  Function()? action;

  /// description about the action
  final String? description;
}

class BrushIntent extends Intent {
  BrushIntent({this.description, required this.action});

  /// undo the last action
  Function()? action;

  /// description about the action
  final String? description;
}

class CanvasIntent extends Intent {
  CanvasIntent({this.description, required this.action});

  /// undo the last action
  Function()? action;

  /// description about the action
  final String? description;
}

class EraserIntent extends Intent {
  EraserIntent({this.description, required this.action});

  /// undo the last action
  Function()? action;

  /// description about the action
  final String? description;
}

class CanvasBuilder extends StatefulWidget {
  const CanvasBuilder({Key? key}) : super(key: key);

  @override
  _CanvasBuilderState createState() => _CanvasBuilderState();
}

class _CanvasBuilderState extends State<CanvasBuilder> {
  late CanvasController _canvasController;

  final FocusNode _canvasFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = Colors.grey[300]!;
    final _toolNotifier = Provider.of<ToolController>(context, listen: false);
    _canvasController = CanvasController();

    void onToolChange(Tool newTool) {
      switch (newTool) {
        case Tool.brush:
          _canvasController.isEraseMode = false;
          _toolNotifier.activeTool = newTool;
          break;
        case Tool.canvas:
          _toolNotifier.activeTool = newTool;
          _canvasController.isEraseMode = false;
          break;
        case Tool.download:
          break;
        case Tool.undo:
          _canvasController.undo();
          break;
        case Tool.redo:
          _canvasController.redo();
          break;
        case Tool.eraser:
          _canvasController.isEraseMode = true;
          _toolNotifier.activeTool = newTool;

          break;
        default:
      }
    }

    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyZ):
            UndoIntent(
          description: 'undo last action',
          action: () {
            _canvasController.undo();
          },
        ),
        LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyY):
            RedoIntent(
          description: 'redo last action',
          action: () {
            _canvasController.redo();
          },
        ),
        LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyB):
            RedoIntent(
          description: 'switch to brush mode',
          action: () => onToolChange(Tool.brush),
        ),
        LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyE):
            RedoIntent(
          description: 'switch to eraser mode',
          action: () => onToolChange(Tool.eraser),
        ),
        LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyC):
            RedoIntent(
          description: 'switch to canvas mode',
          action: () => onToolChange(Tool.canvas),
        ),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          UndoIntent: CallbackAction<UndoIntent>(
              onInvoke: (UndoIntent intent) => intent.action!()),
          RedoIntent: CallbackAction<RedoIntent>(
              onInvoke: (RedoIntent intent) => intent.action!()),
          BrushIntent: CallbackAction<BrushIntent>(
              onInvoke: (BrushIntent intent) => intent.action!()),
          EraserIntent: CallbackAction<EraserIntent>(
              onInvoke: (EraserIntent intent) => intent.action!()),
          CanvasIntent: CallbackAction<CanvasIntent>(
              onInvoke: (CanvasIntent intent) => intent.action!()),
        },
        child: Focus(
          autofocus: true,
          canRequestFocus: true,
          focusNode: _canvasFocus,
          child: Material(
            color: backgroundColor,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 40.0),
                  child: InteractiveViewer(
                      scaleEnabled: true,
                      minScale: 0.01,
                      maxScale: 5.0,
                      child: Consumer<CanvasNotifier>(builder:
                          (context, CanvasNotifier canvas, Widget? child) {
                        return AspectRatio(
                          aspectRatio: aspectRatios[canvas.aspectRatio]!,
                          child: Container(
                            color: backgroundColor,
                            padding: const EdgeInsets.all(100),
                            child: Container(
                                decoration: BoxDecoration(
                                    color: canvas.color,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.3),
                                        blurRadius: 12,
                                        offset: const Offset(5, 5),
                                        spreadRadius: 4,
                                      )
                                    ]),
                                child: Consumer2<BrushNotifier, ToolController>(
                                    builder: (context, brush, tool, child) {
                                  _canvasController.brushColor = brush.color;
                                  _canvasController.backgroundColor =
                                      canvas.color;
                                  _canvasController.strokeWidthh =
                                      tool.activeTool == Tool.eraser
                                          ? brush.eraserSize
                                          : brush.size;
                                  return MouseRegion(
                                    onEnter: (z) {
                                      FocusScope.of(context)
                                          .requestFocus(_canvasFocus);
                                    },
                                    cursor: tool.cursor,
                                    child: CanvasWidget(
                                        canvasController: _canvasController),
                                  );
                                })),
                          ),
                        );
                      })),
                ),
                Container(
                    padding: const EdgeInsets.only(top: 50),
                    alignment: Alignment.topCenter,
                    child: ToolBarView(
                        onToolChange: (Tool newTool) => onToolChange(newTool))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
