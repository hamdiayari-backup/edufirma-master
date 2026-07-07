# Certificate API Documentation

## Overview
This document describes the API endpoints available for retrieving certificates achieved by users.

## Endpoints

### 1. Get Quiz Certificates (Achievements)
**Endpoint:** `GET /api/certificates/achievements`

**Description:** Retrieves all quiz certificates achieved by the authenticated user.

**Authentication:** Required

**Controller:** `App\Http\Controllers\Api\Panel\CertificatesController@achievements`

**Response:**
```json
{
  "status": 1,
  "message": "retrieved",
  "data": [
    {
      "id": 123,
      "quiz_id": 45,
      "user_id": 1063,
      "status": "passed",
      "certificate": {
        "id": 78,
        "brief": "Certificate brief information"
      },
      // ... other quiz result details
    }
  ]
}
```

**Notes:**
- Returns only passed quiz results
- Includes certificate information if available
- Only returns certificates for active quizzes

---

### 2. Get Course/Webinar Certificates
**Endpoint:** `GET /api/webinars/certificates`

**Description:** Retrieves all course/webinar completion certificates achieved by the authenticated user.

**Authentication:** Required

**Controller:** `App\Http\Controllers\Api\Panel\WebinarCertificateController@index`

**Response:**
```json
{
  "status": 1,
  "message": "retrieved",
  "data": {
    "certificates": [
      {
        "id": 45,
        "student_id": 1063,
        "webinar_id": 12,
        "type": "course",
        "created_at": 1764931551,
        // ... other certificate details
      }
    ]
  }
}
```

**Notes:**
- Returns certificates for courses/webinars where the user has 100% completion
- Automatically calculates and creates certificates if conditions are met
- Only returns certificates for purchased and non-refunded courses

---

### 3. Get Specific Certificate (Download)
**Endpoint:** `GET /api/webinars/certificates/{id}`

**Description:** Retrieves/downloads a specific course certificate by ID.

**Authentication:** Required

**Controller:** `App\Http\Controllers\Api\Panel\WebinarCertificateController@show`

**Parameters:**
- `id` (path parameter) - Certificate ID

**Response:** Certificate file/image

**Notes:**
- Returns the certificate image/file
- Only accessible by the certificate owner

---

### 4. Get Quiz Certificate (Download)
**Endpoint:** `GET /api/results/{quizResultId}/show`

**Description:** Generates and retrieves a quiz certificate for a specific quiz result.

**Authentication:** Required

**Controller:** `App\Http\Controllers\Api\Panel\CertificatesController@makeCertificate`

**Parameters:**
- `quizResultId` (path parameter) - Quiz Result ID

**Response:** Certificate file/image

**Notes:**
- Only accessible by the quiz result owner
- Requires the quiz result to have a "passed" status

---

## Additional Endpoints (For Teachers/Instructors)

### Get Created Certificates
**Endpoint:** `GET /api/certificates/created`

**Description:** Retrieves certificates created by the authenticated teacher/instructor.

**Authentication:** Required (Teacher/Instructor level)

**Controller:** `App\Http\Controllers\Api\Panel\CertificatesController@created`

---

### Get Student Certificates
**Endpoint:** `GET /api/certificates/students`

**Description:** Retrieves certificates of students for quizzes created by the authenticated teacher.

**Authentication:** Required (Teacher/Instructor level)

**Controller:** `App\Http\Controllers\Api\Panel\CertificatesController@students`

---

## Authentication
All endpoints require authentication via API token. Include the token in the request headers:
```
Authorization: Bearer {your_api_token}
```

## Base URL
All endpoints are prefixed with `/api/` and are part of the authenticated user routes.

