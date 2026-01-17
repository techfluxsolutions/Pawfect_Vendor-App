import '../libs.dart';

class EarningsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EarningsController>(() => EarningsController());
  }
}

class BankDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BankDetailsController>(() => BankDetailsController());
  }
}

class PaymentMethodsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PaymentMethodsController>(() => PaymentMethodsController());
  }
}

class TransactionHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TransactionHistoryController>(
      () => TransactionHistoryController(),
    );
  }
}
