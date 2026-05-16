# Local Cache (Simple Guide)

## What is local cache?
Local cache means saving a copy of backend data on the device.

So next time the user opens the same screen:
- data can show **immediately** from phone storage,
- then app quietly checks backend for latest updates.

Think of it like:
- **saved copy first**,
- **fresh copy second**.

---

## Why use it?
It makes the app feel faster.

### Good things
- Opens repeat screens quickly.
- Better experience on slow internet.
- Users see data right away instead of spinner only.

### One small downside
- Cached data can be a little old for a short moment,
  until backend refresh finishes.

---

## Simple flow (how it works)

1. User opens screen.
2. App checks local cache.
3. If cache exists, app shows it instantly.
4. App calls backend in background.
5. If backend succeeds:
   - UI updates with fresh data,
   - cache is replaced with latest data.
6. If backend fails:
   - keep showing cached data (if available),
   - show error only if there is no cache.

---

## Technical flow (behind the scenes)

```text
Screen Open
  -> Read Local Cache (by user + feature key)
      -> Cache Found: Render Immediately
      -> No Cache: Show Loading
  -> Fetch Backend Data
      -> Success: Render Fresh Data + Save to Cache
      -> Failure: Keep Cache (or show error if empty)
```

---

## Basic parts you need

### 1) API Client
- Talks to backend.
- Parses response.

### 2) Local Store
- Saves and reads cached JSON.

### 3) Repository
- Connects API + Local Store.
- Usually has:
  - `loadCached...()`
  - `load...()` (network + save cache)

### 4) Screen
- Shows cached data first.
- Refreshes from backend after.

---

## Important rule: cache key per user
Never mix one user’s cached health data with another user.

Use key format like:
- `feature.section.userId`

Examples:
- `dashboard.weekly-health-report.<userId>`
- `health-records.section.<section>.<userId>`

---

## Where this is used in this project

### Dashboard Weekly Health Report
- `lib/features/dashboard/data/weekly_health_report_local_store.dart`
- `lib/features/dashboard/data/weekly_health_report_repository.dart`
- `lib/features/dashboard/presentation/screens/dashboard_screen.dart`

### Health Records Sections
- `lib/features/health_records/data/health_records_local_store.dart`
- `lib/features/health_records/data/health_records_repository.dart`
- `lib/features/health_records/presentation/widgets/health_record_data_screen.dart`

---

## Reuse checklist (quick)
- [ ] Read cache first.
- [ ] Show cache immediately if present.
- [ ] Always call backend after.
- [ ] Save fresh backend response back to cache.
- [ ] Keep cache visible when refresh fails.
- [ ] Use user-scoped cache keys.
