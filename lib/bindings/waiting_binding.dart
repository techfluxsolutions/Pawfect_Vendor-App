import '../libs.dart';

class WaitingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WaitingController>(() => WaitingController());
  }
}
