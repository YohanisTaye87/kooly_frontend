import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
// import 'package:koooly_app/src/shared/constants.dart';

class AheadFormField extends StatelessWidget {
  final String? errorText;
  final String mainText;
  final Widget assetIcon;
  final bool isDisabled;
  final TextStyle textStyle;
  final TextInputAction textInputAction;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool isPassword;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final List<Map<String, dynamic>>? Function(String) suggestion;

  const AheadFormField({
    super.key,
    required this.suggestion,
    this.textStyle = const TextStyle(
      color: Color(0xFF585656),
      fontSize: 16,
      fontWeight: FontWeight.w500,
      height: 1.5,
    ),
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.textInputAction = TextInputAction.next,
    required this.mainText,
    this.isDisabled = false,
    this.errorText,
    this.controller,
    required this.assetIcon,
    this.validator,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Container(
      padding: EdgeInsets.all(size.height / 200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TypeAheadField<Map<String, dynamic>>(
            controller: controller,
            suggestionsCallback: suggestion,
            itemBuilder: (context, suggestion) {
              return ListTile(
                title: Text(suggestion['display_name']),
              );
            },
            onSelected: (Map<String, dynamic> value) {},
          ),
          // TextFormField(
          //   style: textStyle,
          //   validator: validator,
          //   obscureText: isPassword,
          //   controller: controller,
          //   textInputAction: textInputAction,
          //   keyboardType: keyboardType,
          //   enabled: !isDisabled,
          //   decoration: InputDecoration(
          //     suffixIcon: suffixIcon,
          //     enabledBorder: const OutlineInputBorder(
          //       borderSide: BorderSide(color: Colors.transparent),
          //       borderRadius: BorderRadius.all(Radius.circular(15)),
          //     ),
          //     focusedBorder: const OutlineInputBorder(
          //       borderSide: BorderSide(color: Colors.transparent),
          //       borderRadius: BorderRadius.all(Radius.circular(15)),
          //     ),
          //     errorBorder: const OutlineInputBorder(
          //       borderSide: BorderSide(color: Colors.red),
          //       borderRadius: BorderRadius.all(Radius.circular(15)),
          //     ),
          //     focusedErrorBorder: const OutlineInputBorder(
          //       borderSide: BorderSide(color: Colors.red),
          //       borderRadius: BorderRadius.all(Radius.circular(15)),
          //     ),
          //     prefixIcon: !isDisabled
          //         ? Padding(
          //             padding: EdgeInsets.all(size.width / 30),
          //             child: assetIcon,
          //           )
          //         : Container(),
          //     hintText: mainText,
          //     hintStyle: textStyle,
          //     filled: true,
          //     fillColor: Colors.grey[200],
          //     errorText: errorText,
          //   ),
          // ),
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(left: 15.0, top: 5.0),
              child: Text(
                errorText!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}
