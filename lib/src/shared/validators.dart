mixin FormValidators {
  String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email';
    } else {
      String pattern =
          r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
      RegExp regex = RegExp(pattern);
      if (!regex.hasMatch(value)) {
        return 'Enter a valid email address';
      } else {
        return null;
      }
    }
  }

  String? emailNotRequiredValidator(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    } else {
      String pattern =
          r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
      RegExp regex = RegExp(pattern);
      if (!regex.hasMatch(value)) {
        return 'Enter a valid email address';
      } else {
        return null;
      }
    }
  }

  String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a phone number';
    } else if (value.length < 10) {
      return 'Please enter a valid phone number. i.e. 0912345678';
    } else if (!value
        .split('')
        .every((element) => '0123456789+'.contains(element))) {
      return 'Phone number must only contain digits';
    }
    return null;
  }

  String? validateEmpty(String? value) {
    if (value == null || value.isEmpty) {
      return 'Value Can not be empty';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password Can not be empty';
    } else if (value.length < 4) {
      return 'Password should be at least 4 characters';
    }
    return null;
  }
}
String? validateEmail(String? toValidate) {
  final RegExp emailRegExp = RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9._%+-]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
  );

  if (toValidate == null || toValidate.isEmpty) return 'Cannot be empty';
  if (!emailRegExp.hasMatch(toValidate)) return 'Invalid email format';
  return null;
}
