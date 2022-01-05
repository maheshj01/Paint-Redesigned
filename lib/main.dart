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
        ChangeNotifierProvider<Toolbar>(create: (_) => Toolbar()),
      ],
      child: MaterialApp(
          title: 'Flutter Canvas',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
              primarySwatch: Colors.blue,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent),
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
    // List<Widget> _tabsViewBuilder = const [CanvasBuilder(), CreateMode()];

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

class CanvasBuilder extends StatefulWidget {
  const CanvasBuilder({Key? key}) : super(key: key);

  @override
  _CanvasBuilderState createState() => _CanvasBuilderState();
}

class _CanvasBuilderState extends State<CanvasBuilder> {
  late CanvasController _canvasController;

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = Colors.grey[300]!;
    final _brushNotifier = Provider.of<BrushNotifier>(context, listen: false);
    final _canvasNotifier = Provider.of<CanvasNotifier>(context, listen: false);
    final _toolNotifier = Provider.of<Toolbar>(context, listen: false);
    _canvasController = CanvasController();
    _canvasController.brushColor = _brushNotifier.color;
    _canvasController.backgroundColor = _canvasNotifier.color;
    return Material(
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
                child: Consumer<CanvasNotifier>(
                    builder: (context, CanvasNotifier _tool, Widget? child) {
                  return AspectRatio(
                    aspectRatio: aspectRatios[_tool.aspectRatio]!,
                    child: Container(
                      color: backgroundColor,
                      padding: const EdgeInsets.all(100),
                      child: Container(
                          decoration:
                              BoxDecoration(color: _tool.color, boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(5, 5),
                              spreadRadius: 4,
                            )
                          ]),
                          child: Consumer2<BrushNotifier, CanvasNotifier>(
                              builder: (context, brush, canvas, child) {
                            _canvasController.brushColor = brush.color;
                            _canvasController.backgroundColor = canvas.color;
                            _canvasController.strokeWidthh = brush.size;
                            return CanvasWidget(
                                canvasController: _canvasController);
                          })),
                    ),
                  );
                })),
          ),
          Container(
              padding: const EdgeInsets.only(top: 50),
              alignment: Alignment.topCenter,
              child: ToolBarView(
                onToolChange: (Tool newTool) {
                  // TODO: call
                  switch (newTool) {
                    case Tool.brush:
                      _toolNotifier.activeTool = Tool.brush;
                      break;
                    case Tool.canvas:
                      _toolNotifier.activeTool = Tool.canvas;
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
                      _canvasController.clear();
                      break;
                    default:
                  }
                },
              )),
        ],
      ),
    );
  }
}
