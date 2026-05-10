class AppStrings {
  // General
  static const String appTitle = 'RemPass';
  static const String cancel = 'Cancel';
  static const String save = 'Save';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String ok = 'OK';

  // Login Screen
  static const String welcomeBack = 'Welcome Back!';
  static const String loginSubtitle = 'Login to your RemPass account';
  static const String loginButton = 'Login';
  static const String forgotPassword = 'Forgot Password?';
  static const String passwordLabel = 'Password';
  static const String enterPasswordHint = 'Please enter your password';
  static const String loginSuccess = 'Login Successfull!';
  static const String invalidPassword = 'Invalid Password!';
  static const String passwordEmpty = 'Password cannot be empty';
  static const String passwordTooShort =
      'Password must be at least 6 characters';
  static const String passwordResetSuccess = 'Password Reset Successfull!';

  // Forgot Password / Reset
  static const String verifyEmail = 'Verify Email';
  static const String setNewPassword = 'Set New Password';
  static const String enterEmailLabel = 'Enter your Email';
  static const String emailRequired = 'Email is required';
  static const String enterNewPasswordLabel = 'Enter New Password';
  static const String emailNotFound = 'Email not found!';
  static const String verify = 'Verify';

  // Security Questions
  static const String securityQuestionLabel = 'Select Security Question';
  static const String securityAnswerLabel = 'Security Answer';
  static const String securityQuestionRequired = 'Please select a security question';
  static const String securityAnswerRequired = 'Please enter your answer';
  static const String currentAnswerLabel = 'Enter Current Answer';
  static const String currentAnswerRequired = 'Current Answer is required';
  static const String currentAnswerIncorrect = 'Current Answer is incorrect';
  static const String verifyAnswer = 'Verify Answer';

  static const List<String> securityQuestions = [
    'What is your pet\'s name?',
    'What was the name of your first school?',
    'In what city were you born?',
    'What is your mother\'s maiden name?',
    'What was the make of your first car?',
  ];

  // Register Screen
  static const String welcome = 'Welcome!';
  static const String registerSubtitle = 'Create your personal RemPass account';
  static const String registerButton = 'Register';
  static const String firstNameLabel = 'First Name';
  static const String firstNameRequired = 'Please enter your first name';
  static const String lastNameLabel = 'Last Name';
  static const String lastNameRequired = 'Please enter your last name';
  static const String dobLabel = 'Date of Birth';
  static const String dobRequired = 'Please select your date of birth';
  static const String contactLabel = 'Contact';
  static const String contactRequired = 'Please enter your contact number';
  static const String contactInvalid = 'Please enter 10-digit valid number';
  static const String emailLabel = 'Email';
  static const String emailInvalid = 'Please enter a valid email address';
  static const String appPasswordLabel = 'App Password';

  // Profile Screen
  static const String myProfile = 'My Profile';
  static const String logout = 'Logout';
  static const String logoutSuccess = 'Logout Successfull!';
  static const String editProfile = 'Edit Profile';
  static const String profileUpdatedSuccess = 'Profile Updated Successfully!';
  static const String deleteAccount = 'Delete Account';
  static const String deleteAccountWarning =
      'Are you sure you want to delete your account? This action cannot be undone and will erase all your data.';
  static const String accountSettings = 'Account Settings';
  static const String privacyCenter = 'Privacy Center';
  static const String privacyPolicy = 'Privacy Policy';
  static const String termsAndConditions = 'Terms and Conditions';
  static const String general = 'General';
  static const String faq = 'FAQ';
  static const String sendFeedback = 'Send Feedback';
  static const String aboutUs = 'About Us';
  static const String exportPasswords = 'Export Passwords';
  static const String importPasswords = 'Import Passwords';
  static const String changeAppPassword = 'Change App Password';
  static const String currentPassword = 'Current Password';
  static const String currentPasswordRequired = 'Current Password required';
  static const String currentPasswordIncorrect =
      'Current Password is incorrect';
  static const String confirmPassword = 'Confirm Password';
  static const String confirmPasswordRequired = 'Confirm Password required';
  static const String passwordsDoNotMatch = 'Passwords do not match';
  static const String passwordUpdatedSuccess = 'Password Updated Successfully!';

  // Import / Export
  static const String fileIsEmpty = 'File is empty!';
  static const String invalidFileFormat = 'Invalid file format!';
  static const String enterFilePassword = 'Enter file password';
  static const String importCancelled = 'Import cancelled!';
  static const String wrongPasswordOrCorrupted =
      'Wrong password or corrupted file!';
  static const String noNewPasswords = 'No new passwords imported.';
  static const String enterExportPassword = 'Enter export file password';
  static const String passwordsExportedSuccess =
      'Passwords exported successfully!';

  // FAQ Screen
  static const String faqTitle = 'Frequently Asked Questions';
  static const String q1 = 'Q.1. What is a master password?';
  static const String a1 =
      'Your master password is the single, strong password that encrypts and protects all the other passwords stored in your app. It is the only key to your data. We have **zero knowledge** of your master password, which means we can\'t recover it for you if it\'s lost.';
  static const String q2 = 'Q.2. Is my data stored securely?';
  static const String a2 =
      'Yes. All your data is encrypted on your device using standard algorithms before it is saved. This means your passwords are always protected, even if someone were to gain unauthorized access to your device.';
  static const String q3 = 'Q.3. Can I use the app offline?';
  static const String a3 =
      'Yes, you can. The app works primarily by storing data on your device.';
  static const String q4 = 'Q.4. How do I add a new password entry?';
  static const String a4 =
      'To add a new password, go to the main dashboard and tap the \'+\' or \'Add Entry\' button. You\'ll be prompted to enter a website/app name, username, and password. The app can also generate a secure password for you.';
  static const String q5 = 'Q.5. What happens if I forget my master password?';
  static const String a5 =
      'Due to our **zero-knowledge architecture**, we do not have access to your master password and cannot reset it. You have to first verify your registered email and then you can reset it by yourself.';
  static const String q6 = 'Q.6. How can I contact support?';
  static const String a6 =
      'If you have any further questions or encounter any issues, you can contact our support team at rempass.dev@gmail.com';

  // About Us Screen
  static const String aboutUsTitle = 'About Us';
  static const String appSubtitle = 'RemPass\nSecure Password Manager';
  static const String versionLabel = 'Version';
  static const String versionValue = '1.0.0';
  static const String developedByLabel = 'Developed by';
  static const String developerName = 'Abhishek Ganapati Bhat';
  static const String supportEmail = 'rempass.dev@gmail.com';
  static const String descriptionLabel = 'Description';
  static const String appDescription =
      'RemPass is robust Password Manager app which provides you multiple facilities like password saving/generation/import/export etc.';
  static const String copyright = '© 2025 RemPass. All rights reserved.';

  // Home Screen
  static const String helloPrefix = 'Hello, ';
  static const String newPasswordCardTitle = 'New Password';
  static const String newPasswordCardSubtitle =
      'Save your new password with ease';
  static const String addNewButton = 'Add new +';
  static const String securityTipsCardTitle = 'Security Tips';
  static const String securityTipsCardSubtitle =
      'Learn how to protect your data';
  static const String recentlyAdded = 'Recently Added';

  // Item Screen (Saved Passwords)
  static const String savedPasswords = 'Saved Passwords';
  static const String deleteAllPasswords = 'Delete All Passwords';
  static const String deleteAllPasswordsWarning =
      'Are you sure you want to delete all saved passwords? This action cannot be undone.';
  static const String allPasswordsDeleted = 'All passwords deleted!';
  static const String noPasswords = 'No Passwords!';
  static const String usernameLabel = 'Username';
  static const String appNameLabel = 'Application Name';
  static const String usernameColon = 'Username: ';
  static const String passwordColon = 'Password: ';
  static const String close = 'Close';
  static const String passwordDeleted = 'Password Deleted!';
  static const String usernameCopied = 'Username Copied!';
  static const String passwordCopied = 'Password Copied!';
  static const String copyUsername = 'Copy Username';
  static const String copyPassword = 'Copy Password';

  // Add Password Screen
  static const String addPasswordTitle = 'Add Password';
  static const String appOrSiteNameLabel = 'App / Site Name';
  static const String usernameOrEmailLabel = 'Username / Email';
  static const String generateStrongPasswordTooltip =
      'Generate strong password';
  static const String showTooltip = 'Show';
  static const String hideTooltip = 'Hide';
  static const String passwordSaved = 'Password Saved!';
  static const String failedToSave = 'Failed to Save!';
  static const String requiredField = 'Required';
  static const String saving = 'Saving…';
  static const String savePasswordButton = 'Save Password';
}
