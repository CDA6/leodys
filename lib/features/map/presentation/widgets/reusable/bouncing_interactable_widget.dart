import 'package:flutter/material.dart';

class BouncingInteractableWidget extends StatefulWidget {
  final Widget child;
  final int animDurationMs;
  final double lowScale;
  final double highScale;

  const BouncingInteractableWidget({
    super.key,
    required this.child,
    this.animDurationMs = 100,
    this.lowScale = 0.9,
    this.highScale = 1.0,
  });

  @override
  State<StatefulWidget> createState() {
    return _BouncingInteractableWidgetState();
  }
}

class _BouncingInteractableWidgetState
    extends State<BouncingInteractableWidget> {
  final _isPressed = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _isPressed.value = true,
      onPointerUp: (_) => _isPressed.value = false,
      onPointerCancel: (_) => _isPressed.value = false,
      child: ValueListenableBuilder<bool>(
        valueListenable: _isPressed,
        builder: (context, isPressed, child) {
          return AnimatedScale(
            scale: isPressed ? widget.lowScale : widget.highScale,
            duration: Duration(milliseconds: widget.animDurationMs),
            curve: Curves.easeInOutExpo,
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }

  @override
  void dispose() {
    _isPressed.dispose();
    super.dispose();
  }
}
