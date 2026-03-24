class PasswordRequirement {
  const PasswordRequirement({
    required this.description,
    required this.isMet,
  });

  final String description;
  final bool isMet;
}

String? validateEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) {
    return 'Please enter your email address';
  }

  if (email.length < 6 || email.length > 254) {
    return 'Please enter a valid email address';
  }

  final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  if (!emailRegex.hasMatch(email)) {
    return 'Please enter a valid email address';
  }

  return null;
}

String? validateOtp(String? value) {
  final otp = value?.trim() ?? '';
  if (otp.isEmpty) {
    return 'Please enter the 6-digit code';
  }

  if (otp.length != 6 || !RegExp(r'^\d{6}$').hasMatch(otp)) {
    return 'Enter a 6-digit code';
  }

  return null;
}

List<PasswordRequirement> buildPasswordRequirements(String password) {
  return <PasswordRequirement>[
    PasswordRequirement(
      description: 'At least 8 characters',
      isMet: password.length >= 8,
    ),
    PasswordRequirement(
      description: 'Contains one uppercase letter',
      isMet: RegExp(r'[A-Z]').hasMatch(password),
    ),
    PasswordRequirement(
      description: 'Contains one lowercase letter',
      isMet: RegExp(r'[a-z]').hasMatch(password),
    ),
    PasswordRequirement(
      description: 'Contains one number',
      isMet: RegExp(r'\d').hasMatch(password),
    ),
  ];
}

String? validatePassword(String? value) {
  final password = value ?? '';
  if (password.isEmpty) {
    return 'Please enter a password';
  }

  if (password.length < 8) {
    return 'Password must be at least 8 characters';
  }

  if (password.length > 20) {
    return 'Password must be 20 characters or less';
  }

  if (!RegExp(r'[A-Z]').hasMatch(password)) {
    return 'Include at least one uppercase letter';
  }

  if (!RegExp(r'[a-z]').hasMatch(password)) {
    return 'Include at least one lowercase letter';
  }

  if (!RegExp(r'\d').hasMatch(password)) {
    return 'Include at least one number';
  }

  return null;
}

String? validatePasswordConfirmation(String? password, String confirmPassword) {
  if (confirmPassword.isEmpty) {
    return 'Please confirm your password';
  }

  if (password != confirmPassword) {
    return 'Passwords do not match';
  }

  return null;
}
