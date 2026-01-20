class ApiUrls {
  // ══════════════════════════════════════════════════════════════════════════
  // BASE URL
  // ══════════════════════════════════════════════════════════════════════════
  static const String baseUrl = "https://api-dev.pawfectcaring.com/api/vendor";

  // ══════════════════════════════════════════════════════════════════════════
  // AUTH ENDPOINTS
  // ══════════════════════════════════════════════════════════════════════════
  static const String sendOtp = "/send-otp";
  static const String verifyOtp = "/verify-otp";

  // ══════════════════════════════════════════════════════════════════════════
  // ONBOARDING & KYC ENDPOINTS
  // ══════════════════════════════════════════════════════════════════════════
  static const String onboarding = "/onboarding";
  static const String kycStatus = "/kyc-status";

  // ══════════════════════════════════════════════════════════════════════════
  // PROFILE ENDPOINTS
  // ══════════════════════════════════════════════════════════════════════════
  static const String profile = "/profile";
  static const String terms = "/terms";
  static const String privacyPolicy = "/privacy-policy";
  static const String storeStatus = "/store-status";
  static const String reviewStats = "/review-stats";
  static const String helpFaq = "/help-faq";

  // ══════════════════════════════════════════════════════════════════════════
  // PRODUCT ENDPOINTS
  // ══════════════════════════════════════════════════════════════════════════
  static const String products = "/products";

  // Dynamic endpoints (use with string interpolation)
  static String productById(String id) => "/products/$id";
  static String duplicateProduct(String id) => "/products/$id/duplicate";

  // ══════════════════════════════════════════════════════════════════════════
  // ORDER ENDPOINTS
  // ══════════════════════════════════════════════════════════════════════════
  static const String orders = "/orders";

  // Dynamic endpoints (use with string interpolation)
  static String orderById(String id) => "/orders/$id";
  static String updateOrderStatus(String id) => "/orders/$id/status";
  static String cancelOrder(String id) => "/orders/$id/cancel";

  // ══════════════════════════════════════════════════════════════════════════
  // HOME/DASHBOARD ENDPOINTS
  // ══════════════════════════════════════════════════════════════════════════
  static const String dashboardStats = "/dashboard-stats";
  static const String recentOrders = "/recent-orders";
  static const String topSelling = "/top-selling";

  // ══════════════════════════════════════════════════════════════════════════
  // ANALYTICS ENDPOINTS
  // ══════════════════════════════════════════════════════════════════════════
  static const String analytics = "/analytics";

  // ══════════════════════════════════════════════════════════════════════════
  // ALERTS ENDPOINTS
  // ══════════════════════════════════════════════════════════════════════════
  static const String alerts = "/alerts";

  // Dynamic endpoints (use with string interpolation)
  static String resolveAlert(String id) => "/alerts/$id/resolve";

  // ══════════════════════════════════════════════════════════════════════════
  // INVENTORY ENDPOINTS
  // ══════════════════════════════════════════════════════════════════════════
  static const String inventoryStats = "/inventory-stats";
}
