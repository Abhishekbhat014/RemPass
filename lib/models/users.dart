import 'package:hive_flutter/hive_flutter.dart';

part 'users.g.dart';

/// Represents a user in the RemPass application.
/// 
/// This model is stored locally using Hive. It contains sensitive information
/// like the master password and security questions for recovery.
@HiveType(typeId: 0)
class User extends HiveObject {
  /// The user's first name.
  @HiveField(0)
  late String firstName;

  /// The user's last name. 
  /// Note: This field may be empty as it was removed from the registration flow.
  @HiveField(1)
  late String lastName;

  /// Date of Birth, stored in DD/MM/YYYY format.
  @HiveField(2)
  late String dob;

  /// Contact number.
  /// Note: This field may be empty as it was removed from the registration flow.
  @HiveField(3)
  late String contact;

  /// The user's email address.
  @HiveField(4)
  late String email;

  /// The master password for the application.
  @HiveField(5)
  late String password;

  /// The selected security question for password recovery.
  @HiveField(6)
  late String securityQuestion;

  /// The answer to the security question, stored in plain text or encrypted.
  @HiveField(7)
  late String securityAnswer;

  User({
    required this.firstName,
    required this.email,
    required this.password,
    required this.contact,
    required this.dob,
    required this.lastName,
    required this.securityQuestion,
    required this.securityAnswer,
  });
}
