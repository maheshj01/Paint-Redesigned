import 'package:paint_redesigned/point.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'constants/constants.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => Point(),
      child: MaterialApp(
        title: 'Flutter Canvas',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: PaintHome(),
      ),
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

    return Scaffold(
      body: Row(
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
          // This is the main content.
          Expanded(child: _tabsViewBuilder.elementAt(_selectedIndex))
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
      body: Column(
        children: [
          SizedBox(
            height: 100,
          ),
          Flexible(
            child: InteractiveViewer(
              scaleEnabled: true,
              minScale: 0.01,
              maxScale: 5.0,
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  color: Colors.transparent,
                  padding: EdgeInsets.all(100),
                  child: Container(
                    decoration: BoxDecoration(color: Colors.white, boxShadow: [
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//// Mode to create Banners
class CreateMode extends StatefulWidget {
  const CreateMode({Key? key}) : super(key: key);

  @override
  _CreateModeState createState() => _CreateModeState();
}

class _CreateModeState extends State<CreateMode> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Create Mode..🔥'),
    );
  }
}
