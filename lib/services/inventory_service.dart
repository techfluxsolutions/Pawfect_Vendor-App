import '../core/network/api_client.dart';
import '../core/network/api_response.dart';
import '../core/api/api_urls.dart';

class InventoryService {
  final ApiClient _apiClient = ApiClient();

  // ══════════════════════════════════════════════════════════════════════════
  // GET INVENTORY STATS
  // ══════════════════════════════════════════════════════════════════════════
  Future<ApiResponse> getInventoryStats() async {
    try {
      final response = await _apiClient.get(ApiUrls.inventoryStats);
      return response;
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }
}
