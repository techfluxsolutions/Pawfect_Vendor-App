import 'dart:developer';
import '../libs.dart';

class FAQController extends GetxController {
  final ProfileService _profileService = ProfileService();

  var faqs = <FAQModel>[].obs;
  var isLoading = false.obs;
  var expandedIndex = RxInt(-1); // Track which FAQ is expanded

  @override
  void onInit() {
    super.onInit();
    loadFAQs();
  }

  Future<void> loadFAQs() async {
    isLoading.value = true;

    try {
      log('📚 Loading FAQs...');

      final response = await _profileService.getHelpFAQ();

      if (response.success && response.data != null) {
        final faqList = response.data['faqs'] as List<dynamic>?;

        if (faqList != null) {
          faqs.value =
              faqList
                  .map((faq) => FAQModel.fromJson(faq as Map<String, dynamic>))
                  .toList();

          log('✅ ${faqs.length} FAQs loaded');
        } else {
          log('⚠️ No FAQs found in response');
          _loadFallbackFAQs();
        }
      } else {
        log('⚠️ FAQ API failed: ${response.message}');
        _loadFallbackFAQs();
      }
    } catch (e) {
      log('❌ Error loading FAQs: $e');
      _loadFallbackFAQs();
    } finally {
      isLoading.value = false;
    }
  }

  void _loadFallbackFAQs() {
    // Fallback FAQs if API fails
    faqs.value = [
      FAQModel(
        question: 'How do I track my order?',
        answer:
            'You can track your order by going to \'My Orders\' section in the app and selecting the order you want to track.',
      ),
      FAQModel(
        question: 'What payment methods do you accept?',
        answer:
            'We accept credit/debit cards, UPI, net banking, and Cash on Delivery (COD).',
      ),
      FAQModel(
        question: 'How can I return a product?',
        answer:
            'You can request a return within 7 days of delivery through the \'My Orders\' page.',
      ),
      FAQModel(
        question: 'Do you offer international shipping?',
        answer: 'Currently, we only ship within India.',
      ),
      FAQModel(
        question: 'How do I contact customer support?',
        answer:
            'You can reach out to us via the \'Contact Support\' form or email us at support@pawfect.com.',
      ),
    ];
    log('📚 Using fallback FAQs');
  }

  void toggleExpanded(int index) {
    if (expandedIndex.value == index) {
      expandedIndex.value = -1; // Collapse if already expanded
    } else {
      expandedIndex.value = index; // Expand clicked item
    }
  }

  Future<void> refreshFAQs() async {
    await loadFAQs();
  }
}
