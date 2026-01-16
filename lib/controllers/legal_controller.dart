import 'dart:developer';
import '../libs.dart';

class LegalController extends GetxController {
  final ProfileService _profileService = ProfileService();

  // Terms & Conditions
  var isLoadingTerms = false.obs;
  var termsContent = ''.obs;
  var termsError = ''.obs;

  // Privacy Policy
  var isLoadingPrivacy = false.obs;
  var privacyContent = ''.obs;
  var privacyError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Load both documents when controller is initialized
    loadTermsAndConditions();
    loadPrivacyPolicy();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // LOAD TERMS & CONDITIONS
  // ══════════════════════════════════════════════════════════════════════════
  Future<void> loadTermsAndConditions() async {
    try {
      isLoadingTerms.value = true;
      termsError.value = '';

      log('📄 Loading Terms & Conditions...');

      final response = await _profileService.getTermsAndConditions();

      if (response.success && response.data != null) {
        // Handle different response formats safely
        String content = '';
        try {
          if (response.data is Map<String, dynamic>) {
            content = response.data['content']?.toString() ?? '';
          } else if (response.data is String) {
            content = response.data;
          }
        } catch (e) {
          content = '';
        }

        if (content.isNotEmpty) {
          termsContent.value = content;
          log('✅ Terms & Conditions loaded successfully');
        } else {
          _loadFallbackTermsContent();
          log('⚠️ Empty content, using fallback');
        }
      } else {
        // If API fails, show fallback content
        _loadFallbackTermsContent();
        log('⚠️ API failed, using fallback content');
      }
    } catch (e) {
      // If API fails, show fallback content
      _loadFallbackTermsContent();
      log('❌ Terms & Conditions error: $e - Using fallback content');
    } finally {
      isLoadingTerms.value = false;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // LOAD PRIVACY POLICY
  // ══════════════════════════════════════════════════════════════════════════
  Future<void> loadPrivacyPolicy() async {
    try {
      isLoadingPrivacy.value = true;
      privacyError.value = '';

      log('📄 Loading Privacy Policy...');

      final response = await _profileService.getPrivacyPolicy();

      if (response.success && response.data != null) {
        // Handle different response formats safely
        String content = '';
        try {
          if (response.data is Map<String, dynamic>) {
            content = response.data['content']?.toString() ?? '';
          } else if (response.data is String) {
            content = response.data;
          }
        } catch (e) {
          content = '';
        }

        if (content.isNotEmpty) {
          privacyContent.value = content;
          log('✅ Privacy Policy loaded successfully');
        } else {
          _loadFallbackPrivacyContent();
          log('⚠️ Empty content, using fallback');
        }
      } else {
        // If API fails, show fallback content
        _loadFallbackPrivacyContent();
        log('⚠️ API failed, using fallback content');
      }
    } catch (e) {
      // If API fails, show fallback content
      _loadFallbackPrivacyContent();
      log('❌ Privacy Policy error: $e - Using fallback content');
    } finally {
      isLoadingPrivacy.value = false;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // FALLBACK CONTENT
  // ══════════════════════════════════════════════════════════════════════════
  void _loadFallbackTermsContent() {
    termsContent.value = '''
Terms and Conditions

Welcome to Pawfect Vendor App. By using our services, you agree to these terms and conditions.

1. Acceptance of Terms
By accessing and using this application, you accept and agree to be bound by the terms and provision of this agreement.

2. Use of Service
You may use our service for lawful purposes only. You agree not to use the service in any way that violates any applicable federal, state, local, or international law or regulation.

3. User Accounts
When you create an account with us, you must provide information that is accurate, complete, and current at all times. You are responsible for safeguarding the password and for all activities that occur under your account.

4. Privacy Policy
Your privacy is important to us. Please review our Privacy Policy, which also governs your use of the Service.

5. Disclaimer of Warranties
The information on this application is provided on an "as is" basis. To the fullest extent permitted by law, this Company excludes all representations, warranties, conditions and terms.

6. Limitation of Liability
In no event shall Pawfect Vendor App, nor its directors, employees, partners, agents, suppliers, or affiliates, be liable for any indirect, incidental, punitive, consequential, or similar damages.

7. Governing Law
These Terms shall be interpreted and governed by the laws of India, and you submit to the jurisdiction of the state and federal courts located in India for the resolution of any disputes.

Contact Information:
If you have any questions about these Terms and Conditions, please contact us at support@pawfectcaring.com.

Last updated: ${_formatDate(DateTime.now())}
    ''';
  }

  void _loadFallbackPrivacyContent() {
    privacyContent.value = '''
Privacy Policy

At Pawfect Vendor App, we are committed to protecting your privacy and personal information.

1. Information Collection
We collect information you provide directly to us, such as when you create an account, make a purchase, or contact us for support.

2. Use of Information
We use the information we collect to provide, maintain, and improve our services, process transactions, and communicate with you.

3. Information Sharing
We do not sell, trade, or otherwise transfer your personal information to third parties without your consent, except as described in this policy.

4. Data Security
We implement appropriate security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction.

5. User Rights
You have the right to access, update, or delete your personal information. You may also opt out of certain communications from us.

6. Cookies and Tracking
We use cookies and similar tracking technologies to enhance your experience and gather information about visitors and visits to our application.

7. Changes to Policy
We may update this privacy policy from time to time. We will notify you of any changes by posting the new policy on this page.

Data Protection:
- We use industry-standard encryption to protect your data
- Your payment information is processed securely
- We regularly audit our security practices
- We comply with applicable data protection laws

Contact Information:
If you have any questions about this Privacy Policy, please contact us at:
- Email: privacy@pawfectcaring.com
- Phone: +91 1800-XXX-XXXX

Last updated: ${_formatDate(DateTime.now())}
    ''';
  }

  // ══════════════════════════════════════════════════════════════════════════
  // REFRESH BOTH DOCUMENTS
  // ══════════════════════════════════════════════════════════════════════════
  Future<void> refreshAll() async {
    await Future.wait([loadTermsAndConditions(), loadPrivacyPolicy()]);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ══════════════════════════════════════════════════════════════════════════
  String _formatDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
