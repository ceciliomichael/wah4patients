const DEFAULT_ANDROID_APK_URL =
  "https://drive.usercontent.google.com/download?id=1kq3N-5USCaA6wxQKYMFpA5lB2D7HOdV9&export=download&authuser=0";

function isValidHttpUrl(value: string): boolean {
  try {
    const url = new URL(value);
    return url.protocol === "http:" || url.protocol === "https:";
  } catch {
    return false;
  }
}

export function getLandingAndroidApkUrl(): string {
  const configuredUrl = process.env.WAH4P_ANDROID_APK_URL?.trim();

  if (configuredUrl && isValidHttpUrl(configuredUrl)) {
    return configuredUrl;
  }

  return DEFAULT_ANDROID_APK_URL;
}
