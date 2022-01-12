import 'package:flutter/material.dart';
import 'package:paint_redesigned/models/models.dart';
import 'package:provider/provider.dart';

class MessengerController with ChangeNotifier {
  MessengerController({this.controller});

  String? _message;

  Curve _curve = Curves.bounceIn;

  /// duration for long the message is shown

  String get message => _message ?? 'File saved';

  set message(String? value) {
    _message = value;
    notifyListeners();
  }

  Duration _duration = Duration(seconds: 2);

  set duration(Duration duration) {
    _duration = duration;
  }

  Duration get duration => _duration;

  set curve(Curve value) {
    _curve = value;
  }

  Curve get curve => _curve;

  final AnimationController? controller;

  void show(String status) {
    message = status;
    controller!.forward();
    notifyListeners();
  }

  void stop() {
    controller!.stop();
    notifyListeners();
  }

  void reverse() {
    controller!.reverse();
    notifyListeners();
  }
}

class Messenger extends StatefulWidget {
  const Messenger({
    Key? key,
    this.child,
    this.messengerController,
  }) : super(key: key);
  final MessengerController? messengerController;
  final Widget? child;

  @override
  MessengerState createState() => MessengerState();
}

class MessengerState extends State<Messenger>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    if (widget.messengerController == null) {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      );
      _duration = const Duration(seconds: 2);
      curve = Curves.easeInOut;
      message = 'File saved to Downloads';
    } else {
      _controller = widget.messengerController!.controller!;
      _duration = widget.messengerController!.duration;
      curve = widget.messengerController!.curve;
      message = widget.messengerController!.message;
    }

    _tween = Tween<double>(begin: -250, end: 20.0);

    _animation = _tween.animate(
      CurvedAnimation(
        parent: _controller,
        curve: curve,
      ),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(_duration, () {
          _controller.reverse();
        });
      }
    });
  }

  late Duration _duration;

  late AnimationController _controller;
  late Tween _tween;
  late Animation _animation;
  late Curve curve;
  double width = 220;
  late String message;
  @override
  Widget build(BuildContext context) {
    final _messageWidget = Consumer<MessengerController>(
        builder: (context, MessengerController messenger, Widget? child) {
      print('message received ${messenger.message}');
      return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          width: width,
          height: 80,
          alignment: Alignment.center,
          child: Text(messenger.message),
        ),
      );
    });
    return AnimatedBuilder(
        animation: _animation,
        builder: (BuildContext context, Widget? child) {
          return Transform.translate(
            offset: Offset(_animation.value, 0.0),
            child: widget.child ?? _messageWidget,
          );
        });
  }
}
