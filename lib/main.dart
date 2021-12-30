import 'package:paint_redesigned/create_mode.dart';
import 'package:paint_redesigned/drawer.dart';
import 'package:paint_redesigned/point.dart';
import 'package:flutter/material.dart';
import 'package:paint_redesigned/toolbar_view.dart';
import 'package:provider/provider.dart';
import 'constants/constants.dart';
import 'models/toolbar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<Point>(create: (_) => Point()),
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
          home: PaintHome()),
    );
  }
}

class PaintHome extends StatefulWidget {
  const PaintHome({Key? key}) : super(key: key);

  @override
  _PaintHomeState createState() => _PaintHomeState();
}

class _PaintHomeState extends State<PaintHome> {
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    List<Widget> _tabsViewBuilder = [CanvasBuilder(), CreateMode()];

    return Material(
      child: Row(
        children: <Widget>[
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.selected,
            destinations: tabs,
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: _tabsViewBuilder.elementAt(_selectedIndex)),
          EndDrawer()
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 50,
            ),
            ToolBarView(),
            SizedBox(
              height: 20,
            ),
            Flexible(
              child: InteractiveViewer(
                  scaleEnabled: true,
                  minScale: 0.01,
                  maxScale: 5.0,
                  child: Consumer<Toolbar>(
                      builder: (context, Toolbar _tool, Widget? child) {
                    return AspectRatio(
                      aspectRatio: aspectRatios[_tool.aspectRatio]!,
                      child: Container(
                        color: Colors.transparent,
                        padding: EdgeInsets.all(100),
                        child: Container(
                          decoration:
                              BoxDecoration(color: Colors.white, boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              blurRadius: 12,
                              offset: Offset(5, 5),
                              spreadRadius: 4,
                            )
                          ]),
                          child: Container(),
                        ),
                      ),
                    );
                  })),
            ),
          ],
        ),
      ),
    );
  }
}
