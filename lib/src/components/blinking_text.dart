import 'package:flutter/material.dart';

class BlinkingText extends StatefulWidget {
  final String text;
  final TextStyle? textStyle;
  final Duration duration;

  const BlinkingText({
    super.key,
    required this.text,
    this.textStyle,
    this.duration = const Duration(milliseconds: 700),
  });

  @override
  State<BlinkingText> createState() => _BlinkingTextState();
}

class _BlinkingTextState extends State<BlinkingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true); // Repeats the animation indefinitely.

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Text(
        widget.text,
        style: widget.textStyle ?? Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}
