import '../libs.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Bottom navigation controller
    Get.lazyPut<HomeController>(() => HomeController());

    // All bottom navigation screen controllers
    Get.lazyPut<HomeScreenController>(() => HomeScreenController());
    Get.lazyPut<ProductController>(() => ProductController());
    Get.lazyPut<OrderController>(() => OrderController());
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}

class HomeScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeScreenController>(() => HomeScreenController());
  }
}
