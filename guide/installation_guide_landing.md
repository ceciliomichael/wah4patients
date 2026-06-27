# Landing Page Installation Guide

This document outlines the setup process for the Next.js based landing page for WAH4P.

## Prerequisites and Third-Party Applications

Ensure the following tools are installed:

1. Node.js (v18.x or higher) and npm.
2. Docker & Docker Compose (optional): If running via container instead of locally.

## Setup Instructions

### 1. Install Dependencies

Navigate to the landing page directory and install the required Node.js packages.

```bash
cd landing-wah4p
npm install
```

### 2. Environment Configuration

Copy the example environment file to establish your local configuration.

```bash
cp .env.example .env
```

Open `.env` and configure any required variables, such as `WAH4P_ANDROID_APK_URL` if applicable.

### 3. Running the Application

To start the development server with hot-reload enabled:

```bash
npm run dev
```

The application will typically be accessible at `http://localhost:3000` (or the port specified in your environment configuration).

### 4. Code Quality and Formatting

The project uses Biome for linting and formatting. Run the following commands to check code quality:

```bash
# Check for linting errors
npm run lint

# Format code
npm run format
```

### 5. Building for Production

To create an optimized production build and start the server:

```bash
npm run build
npm run start
```

### 6. Running via Docker

Alternatively, you can run the landing page using Docker Compose.

```bash
docker-compose up --build -d
```
