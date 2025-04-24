import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:paint_redesigned/ui/canvas_builder.dart';
import 'package:paint_redesigned/widgets/widgets.dart';
import 'package:provider/provider.dart';
import 'package:window_size/window_size.dart' as window_size;

import 'constants/constants.dart';
import 'models/models.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    window_size.getWindowInfo().then((window) {
      window_size.setWindowMinSize(const Size(1200, 800));
    });
  }

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
          iconTheme: IconThemeData(color: defaultIconColor),
        ),
        home: const PaintHome(),
      ),
    );
  }
}

enum FileDrag { enter, exit, drop }

class PaintHome extends StatefulWidget {
  const PaintHome({super.key});

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
              SizedBox(width: explorerWidth),
            ],
          ),
        ],
      ),
    );
  }
}
