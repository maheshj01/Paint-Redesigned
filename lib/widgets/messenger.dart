import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MessengerController {
  MessengerController(this._controller);
  Curve _curve = Curves.bounceIn;

  /// duration for long the message is shown

  Duration _duration = Duration(seconds: 2);

  set duration(Duration duration) {
    _duration = duration;
  }

  Duration get duration => _duration;

  set curve(Curve value) {
    _curve = value;
  }

  Curve get curve => _curve;

  final AnimationController _controller;

  AnimationController get controller => _controller;

  void start() {
    _controller.forward();
  }

  void stop() {
    _controller.stop();
  }

  void reverse() {
    _controller.reverse();
  }
}

class Messenger extends StatefulWidget {
  const Messenger(
      {Key? key, this.child, this.messengerController, this.message})
      : assert(child != null || message != null,
            'Either message or child must be provided'),
        super(key: key);
  final MessengerController? messengerController;
  final Widget? child;
  final String? message;

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
    } else {
      _controller = widget.messengerController!.controller;
      _duration = widget.messengerController!.duration;
      curve = widget.messengerController!.curve;
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
  @override
  Widget build(BuildContext context) {
    final _messageWidget = Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        width: width,
        height: 80,
        // decoration: BoxDecoration(
        //     color: Colors.transparent, borderRadius: BorderRadius.circular(10)),
        alignment: Alignment.center,
        child: Text(widget.message ?? ''),
      ),
    );
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
