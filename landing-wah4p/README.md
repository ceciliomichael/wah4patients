# WAH for Patients landing page

## Environment variables

Set the Android APK download link with:

```bash
WAH4P_ANDROID_APK_URL=https://example.com/your-app.apk
```

If `WAH4P_ANDROID_APK_URL` is not set, the landing page falls back to the current default download URL.

## Docker Compose

For local Next.js development, put the same variable in `landing-wah4p/.env.local`.

When running through `docker compose`, put the variable in a `.env` file next to `docker-compose.yml` and the container will receive it automatically.
