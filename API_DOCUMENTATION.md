# Collection Agent Backend API Documentation

This document outlines the expected API endpoints and response formats for the Collection Agent Flutter app.

## Base URL
```
http://localhost:8080/api/v1/smartflo
```

## Endpoints

### 1. Get All Users (with optional filtering)

**Endpoint:** `GET /users`

**Query Parameters:**
- `status` (optional): Filter by status - `overdue`, `pending`, `completed`
- `page` (optional): Page number for pagination (default: 1)
- `pageSize` (optional): Number of records per page (default: 50)

**Example Request:**
```
GET /users?status=overdue&page=1&pageSize=50
```

**Response Format:**
```json
{
  "success": true,
  "message": "Users fetched successfully",
  "total": 15,
  "page": 1,
  "pageSize": 50,
  "data": [
    {
      "id": "CF-9921",
      "name": "Rajesh Kumar",
      "chit_id": "CHIT-001",
      "pending_amount": 15000.50,
      "due_date": "2023-10-25T00:00:00.000Z",
      "overdue_days": 30,
      "status": "overdue"
    },
    {
      "id": "CF-9922",
      "name": "Priya Singh",
      "chit_id": "CHIT-002",
      "pending_amount": 25000.00,
      "due_date": "2023-11-10T00:00:00.000Z",
      "overdue_days": 15,
      "status": "overdue"
    }
  ]
}
```

**Error Response:**
```json
{
  "success": false,
  "error": "Invalid status parameter",
  "message": "The status parameter must be one of: overdue, pending, completed"
}
```

---

### 2. Get User by ID

**Endpoint:** `GET /users/{userId}`

**Path Parameters:**
- `userId` (required): The user ID (e.g., CF-9921)

**Example Request:**
```
GET /users/CF-9921
```

**Response Format:**
```json
{
  "success": true,
  "message": "User fetched successfully",
  "data": {
    "id": "CF-9921",
    "name": "Rajesh Kumar",
    "chit_id": "CHIT-001",
    "pending_amount": 15000.50,
    "due_date": "2023-10-25T00:00:00.000Z",
    "overdue_days": 30,
    "status": "overdue"
  }
}
```

**Error Response:**
```json
{
  "success": false,
  "error": "User not found",
  "message": "No user found with ID: CF-9999"
}
```

---

### 3. Initiate Call

**Endpoint:** `POST /initiate-call`

**Request Body:**
```json
{
  "async": 1,
  "customer_number": "+919876543210",
  "agent_number": "+918765432109",
  "custom_data": "customer_id=CF-9921,chit_cycle=14/20"
}
```

**Response Format:**
```json
{
  "success": true,
  "message": "Call initiated successfully",
  "call_id": "CALL-12345-67890",
  "data": {
    "call_id": "CALL-12345-67890",
    "status": "initiated",
    "customer_number": "+919876543210",
    "agent_number": "+918765432109"
  }
}
```

---

### 4. Get Call Status

**Endpoint:** `GET /call-status/{callId}`

**Path Parameters:**
- `callId` (required): The call ID from initiate-call response

**Example Request:**
```
GET /call-status/CALL-12345-67890
```

**Response Format:**
```json
{
  "success": true,
  "message": "Call status fetched successfully",
  "status": "active",
  "data": {
    "call_id": "CALL-12345-67890",
    "status": "active",
    "duration": 125,
    "customer_number": "+919876543210",
    "agent_number": "+918765432109"
  }
}
```

---

### 5. Health Check

**Endpoint:** `GET /health`

**Response Format:**
```json
{
  "status": "ok",
  "message": "Service is healthy"
}
```

---

## User Object Schema

```javascript
{
  id: string,              // Customer ID (e.g., CF-9921)
  name: string,            // Customer full name
  chit_id: string,         // Chit ID (e.g., CHIT-001)
  pending_amount: number,  // Amount pending in rupees
  due_date: ISO8601,       // ISO 8601 datetime string
  overdue_days: number,    // Number of days overdue (0 if not overdue)
  status: string           // Status: 'overdue', 'pending', 'completed'
}
```

## Status Codes

- `200`: Success
- `400`: Bad Request (invalid parameters)
- `401`: Unauthorized
- `404`: Not Found
- `500`: Internal Server Error

## Example Implementation (Spring Boot)

```java
@RestController
@RequestMapping("/api/v1/smartflo")
public class SmartFloController {
    
    @GetMapping("/users")
    public ResponseEntity<?> getUsers(
            @RequestParam(required = false) String status,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "50") int pageSize) {
        // Implementation
    }
    
    @GetMapping("/users/{userId}")
    public ResponseEntity<?> getUserById(@PathVariable String userId) {
        // Implementation
    }
    
    @PostMapping("/initiate-call")
    public ResponseEntity<?> initiateCall(@RequestBody CallRequest request) {
        // Implementation
    }
    
    @GetMapping("/call-status/{callId}")
    public ResponseEntity<?> getCallStatus(@PathVariable String callId) {
        // Implementation
    }
    
    @GetMapping("/health")
    public ResponseEntity<?> health() {
        // Implementation
    }
}
```

## Sample Database Query (SQL)

```sql
-- Get all overdue users
SELECT 
  id,
  name,
  chit_id,
  pending_amount,
  due_date,
  DATEDIFF(CURDATE(), due_date) as overdue_days,
  'overdue' as status
FROM customers
WHERE due_date < CURDATE()
ORDER BY due_date ASC
LIMIT 50;
```

## Notes

- All monetary values are in **Indian Rupees (₹)**
- Dates are in **ISO 8601** format with UTC timezone
- `overdue_days` should be calculated as the difference between current date and due date
- If `overdue_days` is negative or zero, status should be `pending` or `completed`
- Pagination is optional; if not provided, return all results (up to pageSize limit)
