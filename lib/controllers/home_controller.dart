import 'package:get/get.dart';
import '../../services/kyc_status_service.dart';

class HomeController extends GetxController {
  var currentIndex = 0.obs;

  void changeTab(int index) {
    currentIndex.value = index;
  }

  @override
  void onInit() {
    super.onInit();
    // ✅ Start KYC polling when home loads
    KycStatusService.instance.startPolling();
    print('🏠 Home loaded - KYC polling started');
  }

  @override
  void onClose() {
    // ✅ Stop polling when leaving home
    KycStatusService.instance.stopPolling();
    print('🚪 Home closed - KYC polling stopped');
    super.onClose();
  }
}
