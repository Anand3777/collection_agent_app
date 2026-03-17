# Collection Agent Flutter App - Quick Start

## Setup

1. **Install Dependencies**
   `
   flutter pub get
   `

2. **Start Spring Boot Backend**
   `
   cd C:\Users\Admin\fusion\ai-voice-agent
   mvn spring-boot:run
   `

3. **Update Backend URL** (if needed)
   
   Edit lib/services/smartflo_service.dart:
   - For Android Emulator: http://10.0.2.2:8080/api/v1/smartflo
   - For iOS Simulator: http://localhost:8080/api/v1/smartflo
   - For Physical Device: http://YOUR_COMPUTER_IP:8080/api/v1/smartflo

4. **Run the App**
   `
   flutter run
   `

## Features

 Live call integration with SmartFlo API
 Real-time chat interface
 Call timer and status tracking
 Chit payment details display
 Dark theme UI matching reference design

## SmartFlo API Payload

When you tap 'JOIN LIVE CALL', the app sends:

`json
{
  \"async\": 1,
  \"customer_number\": \"+919876543210\",
  \"agent_number\": \"+918765432109\",
  \"custom_data\": \"customer_id=CF-9921,chit_cycle=14/20 Months\"
}
`

## Test Flow

1. Tap 'View Chit Details' on home screen
2. Tap phone icon or 'JOIN LIVE CALL' button
3. App calls Spring Boot backend  SmartFlo API
4. Call status displayed with timer
5. Chat interface becomes active
6. Use 'Approve', 'Send Link', or 'End' buttons

## Troubleshooting

**Connection Error?**
- Ensure Spring Boot is running: http://localhost:8080
- Check backend health: curl http://localhost:8080/api/v1/smartflo/health
- Update baseUrl in smartflo_service.dart

**Call Not Initiating?**
- Verify SmartFlo credentials in backend application.properties
- Check backend logs: grep \"[SMARTFLO-CALL]\" logs/ai-voice-agent.log

---

Created: January 24, 2026
