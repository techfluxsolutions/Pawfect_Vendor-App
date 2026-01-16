import '../core/network/api_client.dart';
import '../core/network/api_response.dart';

class ProfileService {
  final ApiClient _apiClient = ApiClient();

  // ══════════════════════════════════════════════════════════════════════════
  // GET TERMS & CONDITIONS
  // ══════════════════════════════════════════════════════════════════════════
  Future<ApiResponse> getTermsAndConditions() async {
    try {
      final response = await _apiClient.get('/user/terms');
      return response;
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // GET PRIVACY POLICY
  // ══════════════════════════════════════════════════════════════════════════
  Future<ApiResponse> getPrivacyPolicy() async {
    try {
      final response = await _apiClient.get('/user/privacy-policy');
      return response;
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // GET PROFILE DATA
  // ══════════════════════════════════════════════════════════════════════════
  Future<ApiResponse> getProfileData() async {
    try {
      final response = await _apiClient.get('/user/profile');
      return response;
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // UPDATE STORE STATUS
  // ══════════════════════════════════════════════════════════════════════════
  Future<ApiResponse> updateStoreStatus(bool isActive) async {
    try {
      final response = await _apiClient.patch(
        '/user/store-status',
        data: {'isActive': isActive},
      );
      return response;
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }
}
