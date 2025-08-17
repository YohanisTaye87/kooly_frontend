import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class CacheStorage {
  CacheStorage._();
  static final CacheStorage _instance = CacheStorage._();
  factory CacheStorage() {
    return _instance;
  }

  Future<bool> isLoggedIn() async {
    final SharedPreferences storage = await SharedPreferences.getInstance();
    bool? isLoggedIn = storage.getBool('isLoggedIn');
    return isLoggedIn ?? false;
  }

  Future<bool> saveLastCompletedId(String id) async {
    final SharedPreferences storage = await SharedPreferences.getInstance();
    return await storage.setString('lastCompletedId', id);
  }

  Future<String?> getLastCompletedId() async {
    final SharedPreferences storage = await SharedPreferences.getInstance();
    return storage.getString('lastCompletedId');
  }

  Future<bool> isFirstTime() async {
    final SharedPreferences storage = await SharedPreferences.getInstance();
    bool? isFirstTime = storage.getBool('onboarding');

    return isFirstTime ?? true;
  }

  Future<bool> markOnboardingCompleted() async {
    final SharedPreferences storage = await SharedPreferences.getInstance();
    return await storage.setBool('onboarding', false);
  }

  Future<bool> endSession() async {
    final SharedPreferences storage = await SharedPreferences.getInstance();
    await storage.remove("searchTerms");
    await storage.remove("user");
    // Reset onboarding flag so user can go through onboarding again if they want
    await storage.setBool('onboarding', true);
    return true;
  }

  Future<void> saveSearchTerm({
    required Map<String, dynamic> term,
  }) async {
    final SharedPreferences storage = await SharedPreferences.getInstance();
    final searchTerms = storage.getStringList("searchTerms") ?? [];
    searchTerms.add(jsonEncode(term));
    await storage.setStringList('searchTerms', searchTerms);
  }

  Future<List<String>> getSearchHistory() async {
    final SharedPreferences storage = await SharedPreferences.getInstance();
    List<String>? searchTerms = storage.getStringList('searchTerms');

    return searchTerms ?? [];
  }
}
