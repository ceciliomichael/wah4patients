API Reference

# API Reference

Complete documentation of all WAH4PC Gateway API endpoints. Use these endpoints to discover providers, initiate FHIR transfers, and track transactions.

## Base URL

`https://gateway.wah4pc.com`
Replace with your gateway instance URL in production.

## Authentication

API Key Required

Most endpoints require authentication via API key. Include your API key in the request header to access protected resources.

Header Format

`X-API-Key: YOUR_API_KEY_HERE`
Alternative:`Authorization: Bearer YOUR_API_KEY`

### Getting Started

Contact your system administrator to obtain an API key for accessing the gateway.

### Start Here for Payloads

For exact request bodies by resource type, use [/docs/request-formats](/docs/request-formats).

## Health

System health and status (public endpoint)

Endpoint

`/health`
Check if the gateway is running and healthy. This endpoint does not require authentication.

#### Response (200)

json

```
{
  "status": "healthy",
  "service": "wah4pc-gateway"
}
```

## Providers

List registered healthcare providers (public endpoint)

Endpoint

`/api/v1/providers`
List providers for discovery. Response intentionally excludes internal callback routing fields.

#### Headers

| X-API-Key | wah_your-api-key | Optional |
| --- | --- | --- |

#### Response (200)

json

```
[
    {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "name": "Example Hospital",
    "type": "hospital",
    "facility_code": "HOSP-001",
    "location": "Quezon City",
    "isActive": true
    }
  ]
]
```

#### Notes

- •The provider list does not expose internal fields such as `baseUrl`, `gatewayAuthKey`, `practitionerListEndpoint`, or `practitionerList`.
- •Use this endpoint for discovery (`id`, `facility_code`, and `isActive`) before calling data exchange endpoints.

Endpoint

`/api/v1/providers/{id}/practitioners/webhook`
Provider-triggered sync hook. Call this after creating/updating practitioners so the gateway refreshes the cached practitioner list for this provider.

#### Path Parameters

| id | string | Provider ID (UUID). For user API keys, this must match the key's provider scope. |
| --- | --- | --- |

#### Headers

| X-API-Key | wah_your-api-key | Required |
| --- | --- | --- |

#### Response (200)

json

```
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "name": "Example Hospital",
  "type": "hospital",
  "facility_code": "HOSP-001",
  "location": "Quezon City",
  "isActive": true
}
```

#### Notes

- •This webhook triggers the gateway to fetch your configured practitioner list endpoint and update cached practitioners.
- •Recommended trigger timing: immediately after practitioner create, update, or deactivate operations.

## FHIR Gateway

FHIR resource transfer endpoints using resource-specific request formats

Endpoint

`/api/v1/fhir/request/{resourceType}`
Initiate a FHIR query to another provider. Use the resource-specific request body format for the chosen resource type.

#### Path Parameters

| resourceType | string | Supported FHIR resource type (for this gateway's 25-resource allowlist) |
| --- | --- | --- |

#### Headers

| X-API-Key | wah_your-api-key | Required |
| --- | --- | --- |
| Idempotency-Key | 550e8400-e29b-41d4-a716-446655440000 | Optional |

#### Request Body

json

```
{
  "requesterId": "your-provider-uuid",
  "targetId": "target-provider-uuid",
  "patientIdentifiers": [
    {
      "system": "http://philhealth.gov.ph",
      "value": "12-345678901-2"
    }
  ],
  "reason": "Referral consultation",
  "notes": "Need latest lab results"
}
```

#### Response (202)

json

```
{
  "success": true,
  "data": {
    "id": "txn_a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "requesterId": "your-provider-uuid",
    "targetId": "target-provider-uuid",
    "resourceType": "Patient",
    "status": "PENDING",
    "metadata": {
      "reason": "Referral consultation",
      "notes": "Need latest lab results"
    },
    "createdAt": "2026-02-17T11:00:00Z",
    "updatedAt": "2026-02-17T11:00:00Z"
  }
}
```

#### Notes

- •Use `/docs/request-formats` for all 25 request body formats.
- •Both requesterId and targetId must be registered providers.
- •Idempotency-Key is optional but strongly recommended for safe retries on POST requests.
- •The gateway forwards the query to target provider `/fhir/process-query`.
- •Results are sent asynchronously to requester `/fhir/receive-results`.
- •Duplicate requests inside the 5-minute window can return HTTP 429.

Endpoint

`/api/v1/fhir/receive/{resourceType}`
Endpoint used by target providers to send result payloads back to the gateway.

#### Path Parameters

| resourceType | string | FHIR resource type matching the original request |
| --- | --- | --- |

#### Headers

| X-API-Key | wah_your-api-key | Required |
| --- | --- | --- |
| X-Provider-ID | your-provider-uuid | Optional |
| Idempotency-Key | 550e8400-e29b-41d4-a716-446655440000 | Optional |

#### Request Body

json

```
{
  "transactionId": "txn_a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "status": "SUCCESS",
  "data": {
    "resourceType": "Bundle",
    "type": "collection",
    "entry": [
      {
        "resource": {
          "resourceType": "Observation",
          "status": "final",
          "code": {
            "coding": [
              {
                "system": "http://loinc.org",
                "code": "8480-6"
              }
            ]
          }
        }
      }
    ]
  }
}
```

#### Response (200)

json

```
{
  "success": true,
  "data": {
    "message": "result received and processed"
  }
}
```

#### Notes

- •transactionId must match a pending transaction.
- •status values: SUCCESS, REJECTED, ERROR.
- •For SUCCESS, send full FHIR resource payloads (Bundle or resource JSON).
- •For REJECTED/ERROR, `data` must be a FHIR OperationOutcome.
- •Gateway policy currently does not relay REJECTED to requester `/fhir/receive-results`.
- •See `/docs/request-formats` and `format/provider-return-core8.md` for concrete payload formats.

Endpoint

`/api/v1/fhir/push/{resourceType}`
Push a FHIR resource directly to another provider without a prior query (unsolicited transfer).

#### Path Parameters

| resourceType | string | FHIR resource type (e.g., Appointment, Observation) |
| --- | --- | --- |

#### Headers

| X-API-Key | wah_your-api-key | Required |
| --- | --- | --- |
| Idempotency-Key | 550e8400-e29b-41d4-a716-446655440000 | Optional |

#### Request Body

json

```
{
  "senderId": "your-provider-uuid",
  "targetId": "target-provider-uuid",
  "resource": {
    "resourceType": "Appointment",
    "status": "proposed",
    "start": "2026-02-20T09:00:00Z"
  },
  "reason": "New appointment",
  "notes": "Please confirm availability"
}
```

#### Response (200)

json

```
{
  "success": true,
  "data": {
  "id": "txn_a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "requesterId": "your-provider-uuid",
  "targetId": "target-provider-uuid",
  "resourceType": "Appointment",
  "status": "COMPLETED",
  "createdAt": "2026-02-17T11:00:00Z",
  "updatedAt": "2026-02-17T11:00:00Z"
  }
}
```

#### Notes

- •Target provider must support `/fhir/receive-push`.
- •`resource` must be valid FHIR JSON for the given resourceType.
- •Top-level `resourceType` in body is not used. The URL path and `resource.resourceType` must match.
- •Push transactions are completed immediately after successful forward.

## Transactions

View and track FHIR transfer transactions (access controlled by API key role)

Endpoint

`/api/v1/transactions`
List transactions. Admin keys see all transactions. User keys only see transactions where their linked provider is the requester or target.

#### Headers

| X-API-Key | wah_your-api-key | Required |
| --- | --- | --- |

#### Response (200)

json

```
{
  "success": true,
  "data": [
    {
      "id": "txn_a1b2c3d4-e5f6-7890-abcd-ef1234567890",
      "requesterId": "provider-uuid-1",
      "targetId": "provider-uuid-2",
      "identifiers": [
        {
          "system": "http://philhealth.gov.ph",
          "value": "12-345678901-2"
        }
      ],
      "resourceType": "Patient",
      "status": "COMPLETED",
      "metadata": {
        "reason": "Referral",
        "notes": ""
      },
      "createdAt": "2024-01-15T11:00:00Z",
      "updatedAt": "2024-01-15T11:05:00Z"
    }
  ]
}
```

#### Notes

- •Admin API keys: Returns ALL transactions in the system
- •User API keys: Returns only transactions where the linked provider is requester or target
- •Access control is automatic based on the providerId linked to your API key

Endpoint

`/api/v1/transactions/{id}`
Get details of a specific transaction. User keys can only access transactions where their linked provider is involved.

#### Path Parameters

| id | string | Transaction UUID |
| --- | --- | --- |

#### Headers

| X-API-Key | wah_your-api-key | Required |
| --- | --- | --- |

#### Response (200)

json

```
{
  "success": true,
  "data": {
    "id": "txn_a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "requesterId": "provider-uuid-1",
    "targetId": "provider-uuid-2",
    "identifiers": [
      {
        "system": "http://philhealth.gov.ph",
        "value": "12-345678901-2"
      },
      {
        "system": "http://hospital-metro.com/mrn",
        "value": "MRN-12345"
      }
    ],
    "resourceType": "Patient",
    "status": "COMPLETED",
    "metadata": {
      "reason": "Referral consultation",
      "notes": "Urgent request for patient records"
    },
    "createdAt": "2024-01-15T11:00:00Z",
    "updatedAt": "2024-01-15T11:05:00Z"
  }
}
```

#### Notes

- •Admin API keys can access any transaction
- •User API keys can only access transactions where their provider is requester or target
- •Returns 403 Forbidden if user attempts to access unauthorized transaction

## Provider Webhooks

Endpoints you must implement to receive gateway events

Endpoint

`/api/fhir/practitioners`
Endpoint you should implement for practitioner directory sync. The gateway fetches this endpoint to keep your practitioner list current.

#### Headers

| X-Gateway-Auth | your-gateway-auth-key | Required |
| --- | --- | --- |

#### Response (200)

json

```
[
  {
    "code": "prac-001",
    "display": "Dr. Maria Santos",
    "active": true
  },
  {
    "code": "prac-002",
    "display": "Dr. Jose Cruz",
    "active": false
  }
]
```

#### Notes

- •Register this relative path as your `practitionerListEndpoint` (for example `/api/fhir/practitioners`).
- •Return practitioner items with `code`, `display`, and `active` fields.
- •After practitioner changes, trigger `POST /api/v1/providers/{id}/practitioners/webhook` so gateway refreshes cached practitioners.

Endpoint

`/fhir/process-query`
Endpoint you must implement to receive data requests from the gateway. When another provider requests patient data, the gateway will call this endpoint on your system.

#### Headers

| X-Gateway-Auth | your-gateway-auth-key | Required |
| --- | --- | --- |

#### Request Body

json

```
{
  "transactionId": "txn_a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "requesterId": "requester-provider-uuid",
  "resourceType": "Patient",
  "identifiers": [
    {
      "system": "http://philhealth.gov.ph",
      "value": "12-345678901-2"
    }
  ],
  "gatewayReturnUrl": "https://gateway.wah4pc.com/api/v1/fhir/receive/Patient",
  "reason": "Referral consultation",
  "notes": "Patient transferring for specialized care"
}
```

#### Response (200)

json

```
{
  "message": "Processing"
}
```

#### Notes

- •**You must implement this endpoint** on your server at the baseUrl you registered
- •Respond with 200 OK immediately to acknowledge receipt
- •Process the request asynchronously and send results to the gatewayReturnUrl
- •Use the transactionId when sending results back to correlate the response
- •Validate the X-Gateway-Auth header matches your registered gatewayAuthKey
- •For appointment and routing workflows, keep your `/api/fhir/practitioners` list updated and trigger practitioner sync webhook on changes.
- •Use the lookup data in the payload (`identifiers` and other provided fields) to resolve records in your local system.
- •The payload format may evolve; process known lookup fields defensively.
- •The reason and notes fields provide context about why data is being requested

Endpoint

`/fhir/receive-results`
Endpoint you must implement to receive requested data. When data you requested is ready, the gateway will deliver it to this endpoint on your system.

#### Headers

| X-Gateway-Auth | your-gateway-auth-key | Required |
| --- | --- | --- |

#### Request Body

json

```
{
  "transactionId": "txn_a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "status": "SUCCESS",
  "data": {
    "resourceType": "Bundle",
    "type": "collection",
    "entry": [
      {
        "resource": {
          "resourceType": "MedicationRequest",
          "id": "medrx-1",
          "status": "active"
        }
      }
    ]
  }
}
```

#### Response (200)

json

```
{
  "message": "Data received successfully"
}
```

#### Notes

- •**You must implement this endpoint** on your server at the baseUrl you registered
- •The transactionId corresponds to a request you previously initiated
- •Current gateway behavior delivers `SUCCESS` and `ERROR` to requester webhook consumers.
- •`REJECTED` is currently not relayed to requester `/fhir/receive-results` (it is logged in gateway transaction state).
- •When status is SUCCESS, the data field contains a FHIR Bundle (type=collection)
- •When status is ERROR, the data field contains error details (OperationOutcome or gateway-generated error object).
- •Do not assume a single resource object for SUCCESS; always parse Bundle.entry[]
- •Store the received data and update your pending transaction status
- •Validate the X-Gateway-Auth header matches your registered gatewayAuthKey

Endpoint

`/fhir/receive-push`
Endpoint you must implement to receive unsolicited data pushes from other providers (e.g., incoming referrals or appointments).

#### Headers

| X-Gateway-Auth | your-gateway-auth-key | Required |
| --- | --- | --- |

#### Request Body

json

```
{
  "transactionId": "txn_a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "senderId": "sender-provider-uuid",
  "resourceType": "Appointment",
  "resource": {
    "resourceType": "Appointment",
    "status": "proposed",
    "description": "Consultation",
    "participant": [
      {
        "actor": {
          "type": "Patient",
          "identifier": {
            "system": "http://philhealth.gov.ph",
            "value": "12-345678901-2"
          }
        },
        "status": "accepted"
      }
    ]
  },
  "reason": "New Appointment Request",
  "notes": "Please confirm availability"
}
```

#### Response (200)

json

```
{
  "message": "Data received successfully"
}
```

#### Notes

- •**Implement this to support receiving data you didn't explicitly request**
- •This is critical for receiving referrals, appointments, or unsolicited lab results
- •Validate the X-Gateway-Auth header
- •Process and store the received FHIR resource immediately
- •Return 200 OK to acknowledge receipt

## Error Responses

All endpoints return consistent error responses in the following format:

Standard Error Format

{

"error":"Error message describing what went wrong"

}

| Status Code | Meaning | Common Causes |
| --- | --- | --- |
| 400 | Bad Request | Invalid request parameters or malformed request body |
| 401 | Unauthorized | Missing or invalid API key |
| 403 | Forbidden | Valid API key but insufficient permissions for this resource |
| 404 | Not Found | The requested resource does not exist |
| 409 | Conflict | Idempotency key is currently being processed. Retry after a short delay. |
| 429 | Too Many Requests | Rate limit exceeded OR duplicate request detected within 5-minute window |
| 500 | Internal Server Error | An unexpected error occurred on the server |
| 502 | Bad Gateway | Upstream provider forwarding failed or upstream returned an error |

## Rate Limiting

The gateway enforces per-API-key rate limiting to ensure fair usage and system stability. Each API key has a configurable rate limit set during creation.

- iRate limits are enforced per API key and configured during key creation
- iDefault limit is typically 100 requests per minute (subject to configuration)
- iWhen rate limit is exceeded, the gateway returns HTTP 429 with retry-after information
- iImplement exponential backoff in your client when receiving 429 responses
- iContact your administrator to increase rate limits if needed for your use case

Latest updated: February 18, 2026