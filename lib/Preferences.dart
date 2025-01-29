import 'package:shared_preferences/shared_preferences.dart';

class PreferenceService {

  Future<void> saveUserLogin(String num_tel) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userphone', num_tel);
    await prefs.setBool('isLoggedIn', true);
  }

  Future<void> saveUserid(int id_p) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('identifiant', id_p);
  }

  Future<void> savename(String nom) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nom', nom);
  }

  Future<bool> isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  Future<bool> isUserIdExists() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('identifiant');
  }

  Future<void> countview(int countview) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('countview', countview);
  }

  Future<void> saveetat(String etat) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('etat', etat);
  }

  Future<void> logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userphone');
    await prefs.remove('identifiant');
    await prefs.remove('nom');
    await prefs.setBool('isLoggedIn', false);
  }
}

