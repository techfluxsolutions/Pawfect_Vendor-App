# Pawfect Vendor App - Home Dashboard API Documentation

## Overview
This document provides complete API specifications for the Home Dashboard screen of the Pawfect Vendor App. The backend developer should implement these exact endpoints with the specified request/response formats to ensure seamless integration with the mobile app.

## Base URL
```
https://api-dev.pawfectcaring.com/api/vendor
```

## Authentication
All API endpoints require Bearer token authentication:
```
Authorization: Bearer {access_token}
```

---

## 1. Dashboard Statistics API

### Endpoint
```http
GET /dashboard/stats
```

### Description
Fetches comprehensive dashboard statistics including sales data, order counts, and product inventory status.

### Headers
```
Authorization: Bearer {access_token}
Content-Type: application/json
```

### Response Format
```json
{
  "success": true,
  "message": "Dashboard statistics fetched successfully",
  "data": {
    "monthlySales": 45680.50,
    "weeklySales": 12450.75,
    "dailySales": 2340.25,
    "totalOrders": 234,
    "todayOrders": 12,
    "totalProducts": 48,
    "outOfStockProducts": 5,
    "lowStockProducts": 8,
    "pendingSettlements": 15420.30
  }
}
```

### Response Fields
| Field | Type | Description |
|-------|------|-------------|
| `monthlySales` | number | Total sales amount for current month |
| `weeklySales` | number | Total sales amount for current week |
| `dailySales` | number | Total sales amount for today |
| `totalOrders` | integer | Total number of orders |
| `todayOrders` | integer | Number of orders received today |
| `totalProducts` | integer | Total number of products in inventory |
| `outOfStockProducts` | integer | Number of products that are out of stock |
| `lowStockProducts` | integer | Number of products with low stock |
| `pendingSettlements` | number | Amount pending for settlement |

### Error Response
```json
{
  "success": false,
  "message": "Failed to fetch dashboard statistics",
  "error": "Error details here"
}
```

---

## 2. Store Information API

### Endpoint
```http
GET /store/info
```

### Description
Fetches vendor store information including store name, status, and basic details.

### Headers
```
Authorization: Bearer {access_token}
Content-Type: application/json
```

### Response Format
```json
{
  "success": true,
  "message": "Store information fetched successfully",
  "data": {
    "id": "store_12345",
    "name": "Pawfect Pet Store",
    "isActive": true,
    "ownerName": "John Doe",
    "phone": "+91 9876543210",
    "email": "john@pawfectstore.com",
    "address": "123 Pet Street, Mumbai, Maharashtra 400001"
  }
}
```

### Response Fields
| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Unique store identifier |
| `name` | string | Store name |
| `isActive` | boolean | Store active/inactive status |
| `ownerName` | string | Store owner name (optional) |
| `phone` | string | Store contact phone (optional) |
| `email` | string | Store contact email (optional) |
| `address` | string | Store address (optional) |

---

## 3. Update Store Status API

### Endpoint
```http
PUT /store/status
```

### Description
Updates the store active/inactive status.

### Headers
```
Authorization: Bearer {access_token}
Content-Type: application/json
```

### Request Body
```json
{
  "isActive": true
}
```

### Request Fields
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `isActive` | boolean | Yes | New store status (true = active, false = inactive) |

### Response Format
```json
{
  "success": true,
  "message": "Store status updated successfully",
  "data": {
    "isActive": true,
    "updatedAt": "2024-01-15T10:30:00Z"
  }
}
```

---

## 4. Alerts API

### Endpoint
```http
GET /alerts
```

### Description
Fetches current alerts for the vendor including low stock, pending approvals, and new orders.

### Headers
```
Authorization: Bearer {access_token}
Content-Type: application/json
```

### Response Format
```json
{
  "success": true,
  "message": "Alerts fetched successfully",
  "data": {
    "alerts": [
      {
        "type": "lowStock",
        "title": "Low Stock Alert",
        "message": "5 products are running low on stock",
        "count": 5,
        "actionRoute": "/inventory"
      },
      {
        "type": "pendingApproval",
        "title": "Pending Approval",
        "message": "3 products awaiting approval",
        "count": 3,
        "actionRoute": "/products"
      },
      {
        "type": "newOrder",
        "title": "New Orders",
        "message": "2 new orders received",
        "count": 2,
        "actionRoute": "/orders"
      }
    ]
  }
}
```

### Alert Types
| Type | Description |
|------|-------------|
| `lowStock` | Products with low inventory |
| `pendingApproval` | Products awaiting admin approval |
| `newOrder` | New orders received |
| `general` | General notifications |

### Response Fields
| Field | Type | Description |
|-------|------|-------------|
| `type` | string | Alert type (lowStock, pendingApproval, newOrder, general) |
| `title` | string | Alert title |
| `message` | string | Alert description |
| `count` | integer | Number of items related to this alert |
| `actionRoute` | string | Optional route for alert action (optional) |

---

## 5. Recent Orders API

### Endpoint
```http
GET /orders/recent
```

### Description
Fetches recent orders for the vendor dashboard.

### Headers
```
Authorization: Bearer {access_token}
Content-Type: application/json
```

### Query Parameters
| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `limit` | integer | No | 5 | Number of orders to fetch |

### Example Request
```http
GET /orders/recent?limit=5
```

### Response Format
```json
{
  "success": true,
  "message": "Recent orders fetched successfully",
  "data": {
    "orders": [
      {
        "id": "ORD-2024-001",
        "customerName": "John Doe",
        "customerPhone": "+91 9876543210",
        "amount": 1250.00,
        "status": "Pending",
        "date": "2024-01-15T10:30:00Z",
        "itemCount": 3
      },
      {
        "id": "ORD-2024-002",
        "customerName": "Jane Smith",
        "customerPhone": "+91 9876543211",
        "amount": 890.50,
        "status": "Processing",
        "date": "2024-01-15T08:15:00Z",
        "itemCount": 2
      }
    ]
  }
}
```

### Order Status Values
- `Pending` - Order placed, awaiting processing
- `Processing` - Order being prepared
- `Shipped` - Order shipped to customer
- `Delivered` - Order delivered successfully
- `Cancelled` - Order cancelled

### Response Fields
| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Unique order identifier |
| `customerName` | string | Customer name |
| `customerPhone` | string | Customer phone number (optional) |
| `amount` | number | Order total amount |
| `status` | string | Order status |
| `date` | string | Order date in ISO 8601 format |
| `itemCount` | integer | Number of items in order |

---

## 6. Top Selling Products API

### Endpoint
```http
GET /products/top-selling
```

### Description
Fetches top selling products for the vendor dashboard.

### Headers
```
Authorization: Bearer {access_token}
Content-Type: application/json
```

### Query Parameters
| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `limit` | integer | No | 3 | Number of products to fetch |
| `period` | string | No | month | Time period (day, week, month) |

### Example Request
```http
GET /products/top-selling?limit=3&period=month
```

### Response Format
```json
{
  "success": true,
  "message": "Top selling products fetched successfully",
  "data": {
    "products": [
      {
        "id": "prod_001",
        "name": "Premium Dog Food 5kg",
        "imageUrl": "/uploads/products/dog-food-5kg.jpg",
        "price": 1299.00,
        "soldCount": 145,
        "category": "Dog Food",
        "rating": 4.5
      },
      {
        "id": "prod_002",
        "name": "Cat Food Premium 2kg",
        "imageUrl": "/uploads/products/cat-food-2kg.jpg",
        "price": 899.00,
        "soldCount": 132,
        "category": "Cat Food",
        "rating": 4.3
      },
      {
        "id": "prod_003",
        "name": "Dog Treats Pack",
        "imageUrl": "/uploads/products/dog-treats.jpg",
        "price": 349.00,
        "soldCount": 98,
        "category": "Treats",
        "rating": 4.7
      }
    ]
  }
}
```

### Response Fields
| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Unique product identifier |
| `name` | string | Product name |
| `imageUrl` | string | Product image URL (relative path) |
| `price` | number | Product selling price |
| `soldCount` | integer | Number of units sold in the specified period |
| `category` | string | Product category (optional) |
| `rating` | number | Product rating (optional) |

### Image URL Handling
- If `imageUrl` is empty, the app will show a placeholder icon
- If `imageUrl` starts with `http`, it's treated as a full URL
- Otherwise, it's treated as a relative path and prefixed with the base URL

---

## Error Handling

### Standard Error Response Format
```json
{
  "success": false,
  "message": "Error description",
  "error": "Detailed error information",
  "statusCode": 400
}
```

### Common HTTP Status Codes
| Code | Description |
|------|-------------|
| 200 | Success |
| 400 | Bad Request |
| 401 | Unauthorized (Invalid/Missing token) |
| 403 | Forbidden |
| 404 | Not Found |
| 500 | Internal Server Error |

### Error Types
1. **Authentication Errors** (401)
   - Invalid or expired token
   - Missing authorization header

2. **Validation Errors** (400)
   - Invalid request parameters
   - Missing required fields

3. **Server Errors** (500)
   - Database connection issues
   - Internal server errors

---

## Implementation Notes

### 1. Data Consistency
- All monetary values should be in the same currency (INR)
- Dates should be in ISO 8601 format with timezone
- Boolean values should be true/false (not 1/0)

### 2. Performance Considerations
- Dashboard APIs should be optimized for fast response times
- Consider caching frequently accessed data
- Implement pagination for large datasets

### 3. Security
- All endpoints require valid authentication
- Implement rate limiting to prevent abuse
- Validate all input parameters

### 4. Image Handling
- Product images should be optimized for mobile display
- Provide multiple image sizes if possible
- Handle missing images gracefully

### 5. Real-time Updates
- Consider implementing WebSocket or Server-Sent Events for real-time dashboard updates
- Notification count should update in real-time when new alerts arrive

---

## Testing Endpoints

### Sample cURL Commands

#### Get Dashboard Stats
```bash
curl -X GET "https://api-dev.pawfectcaring.com/api/vendor/dashboard/stats" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json"
```

#### Get Store Info
```bash
curl -X GET "https://api-dev.pawfectcaring.com/api/vendor/store/info" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json"
```

#### Update Store Status
```bash
curl -X PUT "https://api-dev.pawfectcaring.com/api/vendor/store/status" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"isActive": true}'
```

#### Get Recent Orders
```bash
curl -X GET "https://api-dev.pawfectcaring.com/api/vendor/orders/recent?limit=5" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json"
```

---

## Mobile App Integration

The mobile app will:
1. Call these APIs on home screen load
2. Handle loading states during API calls
3. Show appropriate error messages for failed requests
4. Cache data locally for offline viewing
5. Implement pull-to-refresh functionality
6. Auto-refresh data periodically

## Notification Count API (Additional)

### Endpoint
```http
GET /notifications/count
```

### Description
Fetches unread notification count for the notification bell.

### Response Format
```json
{
  "success": true,
  "message": "Notification count fetched successfully",
  "data": {
    "unreadCount": 5
  }
}
```

This API documentation provides everything your backend developer needs to implement the Home Dashboard APIs exactly as expected by your mobile app.