# API Endpoints Reference

## Base URL Configuration

**Base URL in DioClient:**
```dart
baseUrl: 'https://api-dev.pawfectcaring.com/api/vendor'
```

This means all endpoints are automatically prefixed with `/api/vendor`.

## Correct Endpoint Usage

### ❌ WRONG (adds extra /vendor or /user)
```dart
_apiClient.get('/vendor/review-stats')  // ❌ Becomes: /api/vendor/vendor/review-stats
_apiClient.get('/user/terms')           // ❌ Becomes: /api/vendor/user/terms
```

### ✅ CORRECT (relative to base URL)
```dart
_apiClient.get('/review-stats')         // ✅ Becomes: /api/vendor/review-stats
_apiClient.get('/terms')                // ✅ Becomes: /api/vendor/terms
_apiClient.get('/privacy-policy')       // ✅ Becomes: /api/vendor/privacy-policy
```

## All Vendor Endpoints

### Profile & Settings
| Endpoint | Method | Full URL |
|----------|--------|----------|
| `/profile` | GET | `/api/vendor/profile` |
| `/store-status` | PATCH | `/api/vendor/store-status` |
| `/review-stats` | GET | `/api/vendor/review-stats` |

### Legal & Documents
| Endpoint | Method | Full URL |
|----------|--------|----------|
| `/terms` | GET | `/api/vendor/terms` |
| `/privacy-policy` | GET | `/api/vendor/privacy-policy` |

### KYC & Onboarding
| Endpoint | Method | Full URL |
|----------|--------|----------|
| `/onboarding` | POST | `/api/vendor/onboarding` |
| `/onboarding` | GET | `/api/vendor/onboarding` |
| `/onboarding` | PUT | `/api/vendor/onboarding` |
| `/kyc-status` | GET | `/api/vendor/kyc-status` |

### Orders
| Endpoint | Method | Full URL |
|----------|--------|----------|
| `/orders` | GET | `/api/vendor/orders` |
| `/orders/:id` | GET | `/api/vendor/orders/:id` |
| `/orders/:id/status` | PATCH | `/api/vendor/orders/:id/status` |

### Products
| Endpoint | Method | Full URL |
|----------|--------|----------|
| `/products` | GET | `/api/vendor/products` |
| `/products` | POST | `/api/vendor/products` |
| `/products/:id` | GET | `/api/vendor/products/:id` |
| `/products/:id` | PUT | `/api/vendor/products/:id` |
| `/products/:id` | DELETE | `/api/vendor/products/:id` |

## Quick Reference

### When writing API calls:

1. **Check the base URL** in `dio_client.dart`
2. **Remove the base URL part** from your endpoint
3. **Start with `/`** for the remaining path

### Example:
```
Full API URL: https://api-dev.pawfectcaring.com/api/vendor/review-stats
Base URL:     https://api-dev.pawfectcaring.com/api/vendor
Endpoint:     /review-stats ✅
```

## Common Mistakes

### ❌ Mistake 1: Including /vendor
```dart
// WRONG
_apiClient.get('/vendor/review-stats')

// RIGHT
_apiClient.get('/review-stats')
```

### ❌ Mistake 2: Including /user
```dart
// WRONG
_apiClient.get('/user/terms')

// RIGHT
_apiClient.get('/terms')
```

### ❌ Mistake 3: Including /api
```dart
// WRONG
_apiClient.get('/api/vendor/terms')

// RIGHT
_apiClient.get('/terms')
```

## Testing Endpoints

To verify your endpoint is correct:

1. Check the error log for the full URL
2. Compare with the expected URL
3. Adjust your endpoint accordingly

### Example Error:
```
URL: https://api-dev.pawfectcaring.com/api/vendor/user/terms
Expected: https://api-dev.pawfectcaring.com/api/vendor/terms
Fix: Change '/user/terms' to '/terms'
```

## Fixed Endpoints

### Profile Service (`profile_service.dart`)
```dart
✅ getTermsAndConditions()    → '/terms'
✅ getPrivacyPolicy()          → '/privacy-policy'
✅ getProfileData()            → '/profile'
✅ updateStoreStatus()         → '/store-status'
✅ getReviewStats()            → '/review-stats'
```

### Onboarding Service (`onboarding_service.dart`)
```dart
✅ submitOnboarding()          → '/onboarding' (POST)
✅ getOnboardingData()         → '/onboarding' (GET)
✅ updateOnboarding()          → '/onboarding' (PUT)
✅ checkKycStatus()            → '/kyc-status' (GET)
```

### KYC Status Service (`kyc_status_service.dart`)
```dart
✅ getCurrentKycStatus()       → '/kyc-status' (GET)
```

## Remember

**Base URL already includes `/api/vendor`**

So your endpoints should be:
- `/endpoint-name` ✅
- NOT `/vendor/endpoint-name` ❌
- NOT `/user/endpoint-name` ❌
- NOT `/api/vendor/endpoint-name` ❌
