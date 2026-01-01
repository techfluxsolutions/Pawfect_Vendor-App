import 'package:get_storage/get_storage.dart';
import 'storage_keys.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  static StorageService get instance => _instance;
  factory StorageService() => _instance;

  late final GetStorage _storage;

  StorageService._internal();

  // Initialize storage
  Future<void> init() async {
    await GetStorage.init();
    _storage = GetStorage();
    print('✅ Storage initialized');
  }

  // ══════════════════════════════════════════════════════════════════════════
  // WRITE DATA
  // ══════════════════════════════════════════════════════════════════════════
  Future<void> write(String key, dynamic value) async {
    await _storage.write(key, value);
    print('💾 Saved: $key = $value');
  }

  // ══════════════════════════════════════════════════════════════════════════
  // READ DATA
  // ══════════════════════════════════════════════════════════════════════════
  T? read<T>(String key) {
    final value = _storage.read<T>(key);
    print('📖 Read: $key = $value');
    return value;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // CHECK IF KEY EXISTS
  // ══════════════════════════════════════════════════════════════════════════
  bool hasData(String key) {
    return _storage.hasData(key);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // REMOVE DATA
  // ══════════════════════════════════════════════════════════════════════════
  Future<void> remove(String key) async {
    await _storage.remove(key);
    print('🗑️ Removed: $key');
  }

  // ══════════════════════════════════════════════════════════════════════════
  // CLEAR ALL DATA
  // ══════════════════════════════════════════════════════════════════════════
  Future<void> clearAll() async {
    await _storage.erase();
    print('🗑️ All data cleared');
  }

  // ══════════════════════════════════════════════════════════════════════════
  // AUTH SPECIFIC METHODS
  // ══════════════════════════════════════════════════════════════════════════

  // Save token
  Future<void> saveToken(String token) async {
    await write(StorageKeys.token, token);
  }

  // Get token
  String? getToken() {
    return read<String>(StorageKeys.token);
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return hasData(StorageKeys.token) && getToken() != null;
  }

  // Save user data
  Future<void> saveUserData({
    required String userId,
    required String mobileNumber,
    required bool isVerified,
    String? userType,
  }) async {
    await write(StorageKeys.userId, userId);
    await write(StorageKeys.mobileNumber, mobileNumber);
    await write(StorageKeys.isVerified, isVerified);
    if (userType != null) {
      await write(StorageKeys.userType, userType);
    }
  }

  // Get user ID
  String? getUserId() {
    return read<String>(StorageKeys.userId);
  }

  // Get mobile number
  String? getMobileNumber() {
    return read<String>(StorageKeys.mobileNumber);
  }

  // Get verification status
  bool isUserVerified() {
    return read<bool>(StorageKeys.isVerified) ?? false;
  }

  // Get user type
  String? getUserType() {
    return read<String>(StorageKeys.userType);
  }

  // Clear auth data (logout)
  Future<void> clearAuthData() async {
    await remove(StorageKeys.token);
    await remove(StorageKeys.userId);
    await remove(StorageKeys.mobileNumber);
    await remove(StorageKeys.isVerified);
    await remove(StorageKeys.userType);
    await remove(StorageKeys.userData);
    print('🔓 Auth data cleared');
  }

  Future<void> saveOnboardingStatus(String status) async {
    // status: 'pending', 'submitted', 'approved', 'rejected'
    await write(StorageKeys.onboardingStatus, status);
  }

  String? getOnboardingStatus() {
    return read<String>(StorageKeys.onboardingStatus);
  }

  Future<void> clearOnboardingStatus() async {
    await remove(StorageKeys.onboardingStatus);
  }
}
