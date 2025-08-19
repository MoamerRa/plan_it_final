import 'package:shared_preferences/shared_preferences.dart';
import '../models/user/user_model.dart';

Future<void> saveUserToPrefs(UserModel user) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('uid', user.id);
  await prefs.setString('name', user.name);
  await prefs.setString('email', user.email);
  await prefs.setString('phone', user.phone);
  await prefs.setString('role', user.role);
  await prefs.setString('customId', user.customId);
}

Future<UserModel?> loadUserFromPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  final uid = prefs.getString('uid');
  final name = prefs.getString('name');
  final email = prefs.getString('email');
  final phone = prefs.getString('phone');
  final role = prefs.getString('role');
  final customId = prefs.getString('customId');

  if (uid != null &&
      name != null &&
      email != null &&
      phone != null &&
      role != null &&
      customId != null) {
    return UserModel(
      id: uid,
      name: name,
      email: email,
      phone: phone,
      role: role,
      customId: customId,
    );
  }
  return null;
}

Future<void> clearUserPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
}
