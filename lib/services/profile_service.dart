import '../core/network/api_client.dart';
import '../core/network/api_response.dart';
import '../core/api/api_urls.dart';

class ProfileService {
  final ApiClient _apiClient = ApiClient();

  // ══════════════════════════════════════════════════════════════════════════
  // GET TERMS & CONDITIONS
  // ══════════════════════════════════════════════════════════════════════════
  Future<ApiResponse> getTermsAndConditions() async {
    try {
      final response = await _apiClient.get(ApiUrls.terms);
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
      final response = await _apiClient.get(ApiUrls.privacyPolicy);
      return response;
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // GET PROFILE DATA
  // ══════════════════════════════════════════════════════════════════════════
  // Future<ApiResponse> getProfileData() async {
  //   try {
  //     final response = await _apiClient.get(ApiUrls.profile);
  //     return response;
  //   } catch (e) {
  //     return ApiResponse.error(message: e.toString());
  //   }
  // }

  // ══════════════════════════════════════════════════════════════════════════
  // UPDATE STORE STATUS
  // ══════════════════════════════════════════════════════════════════════════
  Future<ApiResponse> updateStoreStatus(bool isActive) async {
    try {
      final response = await _apiClient.patch(
        ApiUrls.storeStatus,
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
      final response = await _apiClient.get(ApiUrls.reviewStats);
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
      final response = await _apiClient.get(ApiUrls.helpFaq);
      return response;
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }
}
