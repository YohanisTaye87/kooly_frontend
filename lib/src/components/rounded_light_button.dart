import 'package:flutter/material.dart';
import '../shared/constants.dart';

class RoundedLightButton extends StatelessWidget {
  final String text;

  final bool haSize;
  final Function() onTap;
  final Color color, textColor;
  final bool isColored;
  final double width;
  final double height;
  final TextStyle textStyle;
  const RoundedLightButton({
    super.key,
    required this.text,
    this.isColored = false,
    required this.onTap,
    this.color = kPrimaryColor,
    this.haSize = false,
    this.width = 40,
    this.height = 54,
    this.textStyle = const TextStyle(
      color: Colors.white,
      fontSize: 18,
      //fontFamily: 'Poppins',
      fontWeight: FontWeight.w700,
      height: 0,
    ),
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: haSize ? width : size.width / 1.25,
        height: haSize ? height : size.height / 15,
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 2, color: kPrimaryColor),
            borderRadius: BorderRadius.circular(15),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x26000000),
              blurRadius: 15,
              offset: Offset(2, 2),
              spreadRadius: 0,
            )
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: textStyle,
          ),
        ),
      ),
    );
  }
}
