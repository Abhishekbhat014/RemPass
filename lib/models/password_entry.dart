import 'dart:typed_data';
import 'package:hive_flutter/hive_flutter.dart';

part 'password_entry.g.dart';

/// Represents a stored password entry in the RemPass application.
/// 
/// This model stores the credentials for a specific app or site.
/// The passwords stored here are encrypted using the user's master key
/// before being persisted to the Hive database.
@HiveType(typeId: 1) // Unique typeId for PasswordEntry
class PasswordEntry extends HiveObject {
  /// The name of the application or website.
  @HiveField(0)
  late String appName;

  /// The username or email associated with the account.
  @HiveField(1)
  late String username;

  /// The password for the account.
  @HiveField(2)
  late String password;

  /// The icon of the application, stored as bytes.
  /// This allows displaying the app logo even when offline.
  @HiveField(3)
  Uint8List? appIcon;

  PasswordEntry({
    required this.appName,
    required this.password,
    this.username = "",
    this.appIcon,
  });
}
