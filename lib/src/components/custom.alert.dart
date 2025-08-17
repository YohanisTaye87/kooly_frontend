import 'package:flutter/material.dart';
import 'package:giffy_dialog/giffy_dialog.dart' as giffy;
import 'package:koooly_app/src/shared/constants.dart';

Future showSuccessDialog({
  required BuildContext context,
  required double width,
  required String title,
  required String body,
  required Duration autoCloseDuration,
  required Widget toGoScreen,
}) async {
  final size = MediaQuery.sizeOf(context);
  return showDialog(
    context: context,
    builder: (BuildContext cxt) {
      Future.delayed(autoCloseDuration, () {
        if (cxt.mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => toGoScreen),
            (Route<dynamic> route) => false,
          );
        }
      });

      // Future.delayed(autoCloseDuration, () {
      //   if (context.mounted) {
      //     Navigator.of(context).pop(true);
      //   }
      // });

      return giffy.GiffyDialog.lottie(
        giffy.LottieBuilder.asset(
          "assets/icons/success-gif.json",
          width: size.width / 7,
          height: size.height / 8,
          repeat: false,
          fit: BoxFit.contain,
        ),
        title: SizedBox(
          width: width,
          child: Text(
            title,
            textAlign: TextAlign.center,
            softWrap: true,
            style: TextStyle(
              fontFamily: "Noto",
              fontSize: 0.002 * size.width * 22,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        content: Container(
          margin: const EdgeInsets.only(bottom: 15),
          width: width,
          child: Text(
            body,
            textAlign: TextAlign.center,
            softWrap: true,
            style: TextStyle(fontSize: 0.002 * size.width * 19),
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
      );
    },
  );
}

Future showErrorDialog({
  required BuildContext context,
  required double width,
  required String title,
  required String body,
  required Duration autoCloseDuration,
  bool returnToLogin = false,
  required Widget toGoScreen,
}) async {
  final size = MediaQuery.sizeOf(context);
  return showDialog(
    context: context,
    builder: (BuildContext cxt) {
      if (returnToLogin) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => toGoScreen),
          (Route<dynamic> route) => false,
        );
      } else {
        Future.delayed(autoCloseDuration, () {
          if (cxt.mounted) {
            Navigator.of(context).pop(true);
          }
        });
      }
      return giffy.GiffyDialog.image(
        Image.asset(
          "assets/icons/error-3-gif.gif",
          width: size.width / 7,
          height: size.height / 8,
          fit: BoxFit.contain,
        ),
        title: SizedBox(
          width: width,
          child: Text(
            title,
            textAlign: TextAlign.center,
            softWrap: true,
            style: TextStyle(
              fontSize: 0.002 * size.width * 19,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        content: SizedBox(
          width: width,
          child: Text(
            body,
            textAlign: TextAlign.center,
            softWrap: true,
            style: TextStyle(fontSize: 0.002 * size.width * 19),
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          InkWell(
            onTap: () {
              if (cxt.mounted) {
                if (returnToLogin) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => toGoScreen),
                    (Route<dynamic> route) => false,
                  );
                } else {
                  Navigator.of(context).pop(true);
                }
              }
            },
            child: Container(
              width: width * 1.3,
              margin: const EdgeInsets.only(top: 15, bottom: 15),
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15.0),
              decoration: BoxDecoration(
                color: kPrimaryColor,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Text(
                "ተመለስ",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: "Noto",
                    color: Colors.white,
                    fontSize: 0.002 * size.width * 15),
              ),
            ),
          ),
          // TextButton(
          //   onPressed: () => Navigator.pop(context, 'CANCEL'),
          //   child: const Text('CANCEL'),
          // ),
        ],
      );
    },
  );
}

Future showWarningDialog({
  required BuildContext context,
  required double width,
  required String title,
  required String body,
  required Duration autoCloseDuration,
  required Widget toGoScreen,
}) async {
  final size = MediaQuery.sizeOf(context);
  return showDialog(
    context: context,
    builder: (BuildContext cxt) {
      Future.delayed(autoCloseDuration, () {
        if (cxt.mounted) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  toGoScreen,
              transitionDuration: const Duration(milliseconds: 150),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
            ),
          );
        }
      });

      return giffy.GiffyDialog.image(
        Image.asset(
          "assets/icons/warning-gif.gif",
          width: size.width / 7,
          height: size.height / 8,
          fit: BoxFit.contain,
        ),
        title: SizedBox(
          width: width,
          child: Text(
            title,
            textAlign: TextAlign.center,
            softWrap: true,
            style: TextStyle(
              fontSize: 0.002 * size.width * 19,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        content: SizedBox(
          width: width,
          child: Text(
            body,
            textAlign: TextAlign.center,
            softWrap: true,
            style: TextStyle(fontSize: 0.002 * size.width * 19),
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          InkWell(
            onTap: () {
              if (cxt.mounted) {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        toGoScreen,
                    transitionDuration: const Duration(milliseconds: 150),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                  ),
                );
              }
            },
            child: Container(
              width: width * 1.3,
              margin: const EdgeInsets.only(top: 15, bottom: 15),
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15.0),
              decoration: BoxDecoration(
                color: kPrimaryColor,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Text(
                "Return",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: "Noto",
                    color: Colors.white,
                    fontSize: 0.002 * size.width * 15),
              ),
            ),
          ),
          // TextButton(
          //   onPressed: () => Navigator.pop(context, 'CANCEL'),
          //   child: const Text('CANCEL'),
          // ),
        ],
      );
    },
  );
}
