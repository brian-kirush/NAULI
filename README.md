# nauli_tap
Project Overview
This is an NFC-based payment system that allows users to make payments by tapping registered NFC cards. The system has evolved from using Supabase as the primary database to a custom database solution.

Core Functionality
NFC Card Registration: Register and manage user payment cards

Balance Management: Load funds and track card balances

Tap-to-Pay Processing: Real-time payment processing via NFC taps

Transaction History: Complete audit trail of all transactions

 System Architecture
Technology Stack
Frontend (POS) → Backend API → Database
     ↑                ↑            ↑
  React Native    Node.js/Express  Custom SQL DB
   (Mobile)         (Server)     (Previously Supabase)

   Components Breakdown
1. POS Application (Frontend)
Platform: React Native (iOS/Android)

Key Features:

NFC reader integration

Payment interface

Real-time balance display

Transaction confirmation

Error handling and user feedback

2. Backend API
Framework: Node.js with Express

Key Endpoints:

POST /api/nfc/validate - Card validation and user lookup

POST /api/payment/process - Payment transaction processing

GET /api/users/:id/balance - Balance inquiry

Performance Metrics
Success Criteria
Transaction Success Rate: >99.5%

NFC Read Time: <500ms

Payment Processing: <2 seconds

System Availability: 99.9% uptime

Current Performance (Post-Migration)
Transaction Success Rate: 0% (Critical Issue)

NFC Read Time: ~300ms (Within target)

Payment Processing: N/A (Failing)

System Availability: 95% (Degraded due to failures)



POST /api/cards/register - New card registration
