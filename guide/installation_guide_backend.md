# Backend Installation Guide

This document provides detailed instructions for installing, configuring, and running the WAH4P Backend system locally for development and testing.

## Prerequisites and Third-Party Applications

Ensure the following tools and accounts are set up before proceeding:

1. Node.js (v18.x or higher) and npm.
2. Supabase Account: Required for database and authentication services.
3. Resend Account: Required for sending OTP emails.
4. OpenSSL (optional): For generating secure random keys.
5. Docker & Docker Compose (optional): If running via container instead of locally.

## Setup Instructions

### 1. Install Dependencies

Navigate to the backend directory and install the required Node.js packages.

```bash
cd backend
npm install
```

### 2. Environment Configuration

Copy the example environment file to create your local configuration.

```bash
cp .env.example .env
```

Open `.env` in a text editor and configure the necessary variables. Pay special attention to the following sections:

- Application Port: `PORT=3048` (or your preferred port)
- Supabase Integration:
  - `SUPABASE_URL`: Your Supabase project URL.
  - `SUPABASE_PUBLISHABLE_KEY`: Your Supabase public API key.
  - `SUPABASE_SECRET_KEY`: Your Supabase service role key (keep this secure).
- Email Service (Resend):
  - `RESEND_API_KEY`: Your Resend API key.
  - `RESEND_FROM_EMAIL`: Verified sender email address.
- Security Secrets:
  - Generate random strings for secrets like `BACKEND_API_KEY`, `OTP_HASH_SECRET`, `REGISTRATION_TOKEN_SECRET`, etc. You can use `openssl rand -base64 48` for this.
- Gateway Configuration:
  - `WAH4PC_GATEWAY_URL`, `WAH4PC_API_KEY`, `WAH4PC_PROVIDER_ID` for interoperability.

### 3. Running the Application

To start the server in development mode with hot-reload enabled:

```bash
npm run start:dev
```

To build and run the application for production:

```bash
npm run build
npm run start:prod
```

### 4. Running Tests

The backend uses Jest for testing. You can run unit and end-to-end tests to verify functionality.

```bash
# Run unit tests
npm run test

# Run tests with coverage
npm run test:cov

# Run end-to-end tests
npm run test:e2e
```

### 5. Running via Docker

Alternatively, you can run the backend using Docker Compose.

```bash
docker-compose up --build -d
```
