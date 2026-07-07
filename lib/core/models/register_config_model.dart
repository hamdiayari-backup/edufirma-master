/// Register Config Model - Configuration for registration based on role
class RegisterConfigModel {
  final String? selectedTimezone;
  final List<String> selectRolesDuringRegistration;
  final Object? showOtherRegisterMethod;
  final String? registerMethod;

  bool get showOtherRegisterMethodBool {
    final v = showOtherRegisterMethod;
    if (v == null) return false;
    if (v is bool) return v;
    final s = v.toString();
    return s == '1' || s.toLowerCase() == 'true';
  }

  final bool? showGoogleLoginButton;
  final bool? showFacebookLoginButton;
  final bool? disableRegistrationVerification;
  final FormFields? formFields;

  RegisterConfigModel({
    this.selectedTimezone,
    this.selectRolesDuringRegistration = const [],
    this.showOtherRegisterMethod,
    this.registerMethod,
    this.showGoogleLoginButton,
    this.showFacebookLoginButton,
    this.disableRegistrationVerification,
    this.formFields,
  });

  factory RegisterConfigModel.fromJson(Map<String, dynamic> json) {
    return RegisterConfigModel(
      selectedTimezone: json['selectedTimezone'],
      selectRolesDuringRegistration:
          (json['selectRolesDuringRegistration'] as List<dynamic>?)
                  ?.cast<String>() ??
              [],
      showOtherRegisterMethod: json['showOtherRegisterMethod'],
      registerMethod: json['register_method'],
      showGoogleLoginButton: json['show_google_login_button'],
      showFacebookLoginButton: json['show_facebook_login_button'],
      disableRegistrationVerification:
          json['disable_registration_verification'],
      formFields: json['formFields'] != null
          ? FormFields.fromJson(json['formFields'])
          : null,
    );
  }
}

class FormFields {
  final int? id;
  final String? title;
  final List<FormField> fields;

  FormFields({
    this.id,
    this.title,
    this.fields = const [],
  });

  factory FormFields.fromJson(Map<String, dynamic> json) {
    return FormFields(
      id: json['id'],
      title: json['title'],
      fields: (json['fields'] as List<dynamic>?)
              ?.map((v) => FormField.fromJson(v))
              .toList() ??
          [],
    );
  }
}

class FormField {
  final int? id;
  final String? type;
  final int? isRequired;
  final String? title;
  final List<FormFieldOption> options;

  // User's input value
  dynamic userSelectedData;

  FormField({
    this.id,
    this.type,
    this.isRequired,
    this.title,
    this.options = const [],
    this.userSelectedData,
  });

  factory FormField.fromJson(Map<String, dynamic> json) {
    // Get title from translations if available
    String? title = json['title'];
    if (json['translations'] != null && json['translations'] is List) {
      for (var trans in json['translations']) {
        if (trans['locale'] == 'fr' || trans['locale'] == 'en') {
          title = trans['title'] ?? title;
          break;
        }
      }
    }

    return FormField(
      id: json['id'],
      type: json['type'],
      isRequired: json['required'],
      title: title,
      options: (json['options'] as List<dynamic>?)
              ?.map((v) => FormFieldOption.fromJson(v))
              .toList() ??
          [],
    );
  }

  bool get required => isRequired == 1;
}

class FormFieldOption {
  final int? id;
  final String? title;

  FormFieldOption({
    this.id,
    this.title,
  });

  factory FormFieldOption.fromJson(Map<String, dynamic> json) {
    // Get title from translations if available
    String? title = json['title'];
    if (json['translations'] != null && json['translations'] is List) {
      for (var trans in json['translations']) {
        if (trans['locale'] == 'fr' || trans['locale'] == 'en') {
          title = trans['title'] ?? title;
          break;
        }
      }
    }

    return FormFieldOption(
      id: json['id'],
      title: title,
    );
  }
}
