import 'package:flutter/material.dart';
import '../shared/constants.dart';

class RoundedButton extends StatelessWidget {
  final String text;
  final Function() onTap;
  final Color? color, textColor;

  final double width;
  final double? height;
  final TextStyle? textStyle;
  final bool enable;
  final Widget? leading;
  final bool isLoading;
  const RoundedButton({
    super.key,
    required this.text,
    required this.onTap,
    this.enable = true,
    this.color = kPrimaryColor,
    required this.width,
    this.height,
    this.leading,
    this.textStyle,
    this.textColor = Colors.white,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);

    return GestureDetector(
      onTap: (enable && !isLoading) ? onTap : null,
      child: Container(
        width: width,
        height: height ?? size.height / 15,
        decoration: ShapeDecoration(
          color: color ?? kPrimaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : leading != null
                  ? Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(15.0, 8.0, 8.0, 8.0),
                          child: leading!,
                        ),
                        Text(
                          text,
                          style: textStyle ??
                              TextStyle(
                                color: Colors.white,
                                fontSize: 18 * size.width * 0.002,
                                //fontFamily: 'Poppins',
                                fontWeight: FontWeight.w700,
                                height: 0,
                              ),
                        ),
                      ],
                    )
                  : Text(
                      text,
                      style: textStyle ??
                          TextStyle(
                            color: Colors.white,
                            fontSize: 18 * size.width * 0.002,
                            //fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                            height: 0,
                          ),
                    ),
        ),
      ),
    );
  }
}
