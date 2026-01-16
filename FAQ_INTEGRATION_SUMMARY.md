# FAQ Integration Summary

## API Integration

### Endpoint
```
GET /api/vendor/help-faq
```

### Response
```json
{
  "success": true,
  "faqs": [
    {
      "question": "How do I track my order?",
      "answer": "You can track your order by going to 'My Orders' section..."
    },
    {
      "question": "What payment methods do you accept?",
      "answer": "We accept credit/debit cards, UPI, net banking, and COD."
    }
  ]
}
```

## Files Created

### 1. Model (`lib/models/faq_model.dart`)
```dart
class FAQModel {
  final String question;
  final String answer;
  
  factory FAQModel.fromJson(Map<String, dynamic> json)
}
```

### 2. Controller (`lib/controllers/faq_controller.dart`)
- Fetches FAQs from API
- Handles loading state
- Provides fallback FAQs if API fails
- Manages expansion state for accordion

**Key Features:**
- `loadFAQs()` - Fetches from API
- `_loadFallbackFAQs()` - Provides default FAQs on error
- `toggleExpanded()` - Manages accordion expansion
- `refreshFAQs()` - Pull-to-refresh support

### 3. Screen (`lib/views/faq_screen/faq_screen.dart`)
Beautiful accordion-style FAQ screen with:
- Loading indicator
- Empty state
- Pull-to-refresh
- Expandable FAQ items
- Icon indicators

### 4. Service (`lib/services/profile_service.dart`)
Added `getHelpFAQ()` method

### 5. Routes
- Added `AppRoutes.faq = '/faq'`
- Added route binding in `app_pages.dart`
- Updated `profile_controller.dart` to navigate to FAQ

## Features

### ✅ API Integration
- Fetches real FAQs from backend
- Parses JSON response
- Maps to FAQModel objects

### ✅ Error Handling
- Shows fallback FAQs if API fails
- No error messages to user (graceful degradation)
- Logs errors for debugging

### ✅ Loading States
- Shows spinner while loading
- Shows empty state if no FAQs
- Shows FAQ list when loaded

### ✅ User Experience
- Accordion-style expansion
- One FAQ open at a time
- Pull-to-refresh
- Smooth animations
- Clean, modern design

### ✅ Fallback Content
If API fails, shows 5 default FAQs:
1. How do I track my order?
2. What payment methods do you accept?
3. How can I return a product?
4. Do you offer international shipping?
5. How do I contact customer support?

## UI Design

### Loading State
```
┌─────────────────────────────────────┐
│ Help & FAQ                          │
├─────────────────────────────────────┤
│                                     │
│         🔄 Loading...               │
│                                     │
└─────────────────────────────────────┘
```

### FAQ List (Collapsed)
```
┌─────────────────────────────────────┐
│ Help & FAQ                          │
├─────────────────────────────────────┤
│ ┌─────────────────────────────────┐ │
│ │ ❓ How do I track my order?  ▼ │ │
│ └─────────────────────────────────┘ │
│ ┌─────────────────────────────────┐ │
│ │ ❓ What payment methods...    ▼ │ │
│ └─────────────────────────────────┘ │
│ ┌─────────────────────────────────┐ │
│ │ ❓ How can I return...        ▼ │ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

### FAQ List (Expanded)
```
┌─────────────────────────────────────┐
│ Help & FAQ                          │
├─────────────────────────────────────┤
│ ┌─────────────────────────────────┐ │
│ │ ❓ How do I track my order?  ▲ │ │
│ ├─────────────────────────────────┤ │
│ │ You can track your order by     │ │
│ │ going to 'My Orders' section... │ │
│ └─────────────────────────────────┘ │
│ ┌─────────────────────────────────┐ │
│ │ ❓ What payment methods...    ▼ │ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

### Empty State
```
┌─────────────────────────────────────┐
│ Help & FAQ                          │
├─────────────────────────────────────┤
│                                     │
│           ❓                        │
│      No FAQs Available              │
│   Please check back later           │
│                                     │
└─────────────────────────────────────┘
```

## Navigation

### From Profile Screen:
```
Profile Screen
    ↓
Click "Help & FAQ"
    ↓
Navigate to FAQ Screen
    ↓
Load FAQs from API
    ↓
Display in accordion
```

## Testing Checklist

- [ ] API returns FAQs → Display in accordion
- [ ] API fails → Show fallback FAQs
- [ ] No FAQs → Show empty state
- [ ] Click FAQ → Expands to show answer
- [ ] Click expanded FAQ → Collapses
- [ ] Click another FAQ → Previous collapses, new expands
- [ ] Pull to refresh → Reloads FAQs
- [ ] Loading state → Shows spinner
- [ ] Navigate from Profile → Opens FAQ screen
- [ ] Back button → Returns to Profile

## Code Flow

```
User clicks "Help & FAQ" in Profile
    ↓
ProfileController.navigateToFAQ()
    ↓
Get.toNamed(AppRoutes.faq)
    ↓
FAQScreen loads
    ↓
FAQController.onInit()
    ↓
loadFAQs()
    ↓
ProfileService.getHelpFAQ()
    ↓
API: GET /api/vendor/help-faq
    ↓
Success: Parse FAQs
Failure: Load fallback FAQs
    ↓
Display in accordion UI
```

## Benefits

✅ **Real-time Data**: Fetches latest FAQs from backend  
✅ **Graceful Degradation**: Shows fallback content on error  
✅ **User-Friendly**: Accordion design, easy to navigate  
✅ **Pull-to-Refresh**: Users can manually refresh  
✅ **Loading States**: Clear feedback during loading  
✅ **Empty State**: Handles no FAQs scenario  
✅ **Clean Code**: Separated model, controller, view  
✅ **Reusable**: FAQModel can be used elsewhere  

## Future Enhancements

- [ ] Search functionality
- [ ] Categories/sections for FAQs
- [ ] "Was this helpful?" feedback
- [ ] Contact support button in FAQ
- [ ] Share FAQ feature
- [ ] Bookmark favorite FAQs
