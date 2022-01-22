import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:paint_redesigned/canvas.dart';
import 'package:flutter/material.dart';
import 'package:paint_redesigned/toolbar_view.dart';
import 'package:paint_redesigned/widgets/widgets.dart';
import 'package:window_size/window_size.dart' as window_size;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'constants/constants.dart';
import 'models/models.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  window_size.getWindowInfo().then((window) {
    window_size.setWindowMinSize(const Size(1200, 800));
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  /// Rebuilds the native menu bar based on the current state.
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

enum FileDrag { enter, exit, drop }

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

class DownloadIntent extends Intent {
  DownloadIntent({this.description, required this.action});

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

final key = GlobalKey();

class _CanvasBuilderState extends State<CanvasBuilder>
    with SingleTickerProviderStateMixin {
  late CanvasController _canvasController;

  final FocusNode _canvasFocus = FocusNode();

  Future<void> generateImageBytes({double ratio = 1.5}) async {
    if (_canvasController.isEmpty) return;
    final RenderRepaintBoundary boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final ui.Image image = await boundary.toImage();
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List pngBytes = byteData!.buffer.asUint8List();
    await saveFile(pngBytes);
    // imageNotifier.value = false;
  }

  Future<void> saveFile(Uint8List data) async {
    try {
      final now = DateTime.now().microsecondsSinceEpoch;
      final _downloadsDirectory = await getDownloadsDirectory();
      File file2 = File("${_downloadsDirectory!.path}/$now.png");
      await file2.writeAsBytes(List.from(data));
      _messengerController.show('File changed');
    } catch (_) {
      _messengerController.show('Failed to save the file');
    }
  }

  late MessengerController _messengerController;

  @override
  void initState() {
    super.initState();
    _messengerController = MessengerController(
        controller: AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    ));
    _messengerController.curve = Curves.easeInOut;
  }

  final _fileDragNotifier = ValueNotifier<FileDrag?>(null);

  Future<ui.Image> loadUiImage(String imageAssetPath) async {
    final ByteData data = await rootBundle.load(imageAssetPath);
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(Uint8List.view(data.buffer), (ui.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }

  int getHeight(String aspectRatio) {
    final split = aspectRatio.split(':');
    final height = int.parse(split[1]);
    final width = int.parse(split[0]);
    return (700 * height / width).toInt();
  }

  final canvasKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = Colors.grey[300]!;
    final _toolNotifier = Provider.of<ToolController>(context, listen: false);
    final _canvasNotifier = Provider.of<CanvasNotifier>(context, listen: false);
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
          generateImageBytes();
          WidgetsBinding.instance!.addPostFrameCallback((z) {});
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

    /// command on mac and ctrl on linux, windonws
    final platformKey =
        Platform.isMacOS ? LogicalKeyboardKey.meta : LogicalKeyboardKey.control;

    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(platformKey, LogicalKeyboardKey.keyZ): UndoIntent(
          description: 'undo last action',
          action: () {
            _canvasController.undo();
          },
        ),
        LogicalKeySet(platformKey, LogicalKeyboardKey.keyY): RedoIntent(
          description: 'redo last action',
          action: () {
            _canvasController.redo();
          },
        ),
        LogicalKeySet(platformKey, LogicalKeyboardKey.keyB): RedoIntent(
          description: 'switch to brush mode',
          action: () => onToolChange(Tool.brush),
        ),
        LogicalKeySet(platformKey, LogicalKeyboardKey.keyE): RedoIntent(
          description: 'switch to eraser mode',
          action: () => onToolChange(Tool.eraser),
        ),
        LogicalKeySet(platformKey, LogicalKeyboardKey.keyC): RedoIntent(
          description: 'switch to canvas mode',
          action: () => onToolChange(Tool.canvas),
        ),
        LogicalKeySet(platformKey, LogicalKeyboardKey.keyS): RedoIntent(
          description: 'switch to download mode',
          action: () => onToolChange(Tool.download),
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
                          key: canvasKey,
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
                                  _canvasController.background =
                                      canvas.background;
                                  return MouseRegion(
                                      onEnter: (z) {
                                        FocusScope.of(context)
                                            .requestFocus(_canvasFocus);
                                      },
                                      cursor: tool.cursor,

                                      /// Todo: ValueNotifier not in use right now
                                      /// to be used for image manipualation
                                      child: ValueListenableBuilder<FileDrag?>(
                                        valueListenable: _fileDragNotifier,
                                        builder: (context, FileDrag? _fileDrag,
                                            Widget? child) {
                                          return RepaintBoundary(
                                            key: key,
                                            child: DropTarget(
                                              onDragEntered: (x) {
                                                _fileDragNotifier.value =
                                                    FileDrag.enter;
                                              },
                                              onDragExited: (x) {
                                                _fileDragNotifier.value =
                                                    FileDrag.exit;
                                              },
                                              onDragDone: (x) async {
                                                _fileDragNotifier.value =
                                                    FileDrag.drop;
                                                final path = x.files.first.path;
                                                // final image =
                                                //     await loadUiImage(path);
                                                final imageBytes = File('$path')
                                                    .readAsBytesSync();
                                                // final ui.Image? image =
                                                //     await decodeImageFromList(
                                                //       imageBytes);
                                                final codec = await ui
                                                    .instantiateImageCodec(
                                                  imageBytes,
                                                  targetHeight: getHeight(
                                                      canvas.aspectRatio),
                                                  targetWidth: 700,
                                                );
                                                final image =
                                                    (await codec.getNextFrame())
                                                        .image;
                                                _canvasController.image = image;
                                                _canvasNotifier.background =
                                                    CanvasBackground.image;
                                              },
                                              child: Stack(
                                                children: [
                                                  CanvasWidget(
                                                      canvasController:
                                                          _canvasController),
                                                  if (_fileDrag ==
                                                      FileDrag.enter)
                                                    Positioned.fill(
                                                      child: Container(
                                                        color: Colors.grey
                                                            .withOpacity(0.2),
                                                        child: const Center(
                                                          child: Text(
                                                            'Drop Image',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 20),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ));
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
                Positioned(
                    child: Messenger(
                      messengerController: _messengerController,
                    ),
                    top: 20,
                    left: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
