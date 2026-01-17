import '../libs.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();
  final StorageService _storage = StorageService.instance;

  Future<ApiResponse> sendOtp(String mobile) async {
    try {
      String cleanMobile = mobile.replaceAll(RegExp(r'[^0-9]'), '');

      final response = await _apiClient.post(
        ApiUrls.sendOtp,
        data: {"mobileNumber": cleanMobile},
      );

      return response;
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  Future<ApiResponse<AuthResponseModel>> verifyOtp({
    required String mobile,
    required String otp,
  }) async {
    try {
      String cleanMobile = mobile.replaceAll(RegExp(r'[^0-9]'), '');

      final response = await _apiClient.post(
        ApiUrls.verifyOtp,
        data: {"mobileNumber": cleanMobile, "otp": otp},
      );

      if (response.success && response.data != null) {
        // Parse the response
        final authResponse = AuthResponseModel.fromJson(response.data);

        // Save token and user data
        await _saveAuthData(authResponse);

        return ApiResponse.success(
          data: authResponse,
          message: response.message,
        );
      }

      return ApiResponse.error(message: response.message);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  Future<void> _saveAuthData(AuthResponseModel authResponse) async {
    // Save token
    await _storage.saveToken(authResponse.token);

    // Save user data
    await _storage.saveUserData(
      userId: authResponse.user.id,
      mobileNumber: authResponse.user.mobileNumber,
      isVerified: authResponse.user.isVerified,
      userType: authResponse.user.userType,
    );

    // Set token in Dio headers
    DioClient.instance.setToken(authResponse.token);

    print('✅ Auth data saved to storage');
    print('🔑 Token: ${authResponse.token}');
    print('👤 User ID: ${authResponse.user.id}');
    print('📱 Mobile: ${authResponse.user.mobileNumber}');
    print('✓ Verified: ${authResponse.user.isVerified}');
  }

  Future<void> logout() async {
    await _storage.clearAuthData();
    await _storage.clearOnboardingStatus();
    DioClient.instance.clearToken();
    print('🔓 User logged out');
  }

  bool isLoggedIn() {
    return _storage.isLoggedIn();
  }
}
