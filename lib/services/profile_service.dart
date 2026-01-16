import '../core/network/api_client.dart';
import '../core/network/api_response.dart';

class ProfileService {
  final ApiClient _apiClient = ApiClient();

  // ══════════════════════════════════════════════════════════════════════════
  // GET TERMS & CONDITIONS
  // ══════════════════════════════════════════════════════════════════════════
  Future<ApiResponse> getTermsAndConditions() async {
    try {
      final response = await _apiClient.get(
        '/terms',
      ); // ✅ Fixed: Remove /user prefix
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
      final response = await _apiClient.get(
        '/privacy-policy',
      ); // ✅ Fixed: Remove /user prefix
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
      final response = await _apiClient.get('/profile');
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

  // ══════════════════════════════════════════════════════════════════════════
  // GET REVIEW STATS
  // ══════════════════════════════════════════════════════════════════════════
  Future<ApiResponse> getReviewStats() async {
    try {
      final response = await _apiClient.get('/review-stats');
      return response;
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // GET HELP & FAQ
  // ══════════════════════════════════════════════════════════════════════════
  Future<ApiResponse> getHelpFAQ() async {
    try {
      final response = await _apiClient.get('/help-faq');
      return response;
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }
}
