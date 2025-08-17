import 'package:flutter/material.dart';

class BottomBarButton extends StatefulWidget {
  final double width;
  final double height;
  final Color backgroundColor;
  final String label;
  final bool isHome;
  final TextStyle labelStyle;
  final Function() onTap;
  final Widget icon;
  const BottomBarButton(
      {required this.width,
      required this.height,
      required this.label,
      this.isHome = false,
      this.backgroundColor = Colors.transparent,
      required this.onTap,
      this.labelStyle = const TextStyle(color: Colors.black),
      required this.icon,
      super.key});

  @override
  State<BottomBarButton> createState() => _BottomBarButtonState();
}

class _BottomBarButtonState extends State<BottomBarButton> {
  Color? containerColor;
  @override
  void initState() {
    super.initState();
    containerColor = widget.backgroundColor;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: widget.onTap,
        onLongPress: () {
          setState(() {
            containerColor = const Color(0xFFA1C0EF);
          });
        },
        onLongPressEnd: (var det) {
          containerColor = widget.backgroundColor;
        },
        child: Container(
          width: widget.width,
          height: widget.height,
          color: containerColor,
          child: Column(children: [
            widget.icon,
            Visibility(
              visible: !widget.isHome,
              child: SizedBox(
                height: widget.height / 30,
              ),
            ),
            Visibility(
              visible: !widget.isHome,
              child: Text(
                widget.label,
                style: widget.labelStyle,
                overflow: TextOverflow.ellipsis,
              ),
            )
          ]),
        ));
  }
}
