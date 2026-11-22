# Funngro – Mobile Engineer (Flutter) Assessment

Flutter + **GetX** (state management, navigation) + **http** (API calls), in a simple MVC folder structure.

## Run it

```bash
flutter pub get
flutter run            # use --profile on a real device to judge performance
```

The home screen has two buttons: **Part 1 – My Earnings** and **Part 2 – Projects**.

There's no real backend, so `main.dart` points `HttpHelper` at a fake client (`helpers/fake_backend.dart`). It returns 3,000 earnings (the worst-case user) and makes detail calls fail 1 in 5 times so the error path is visible.

## Where things are

```
lib/
  main.dart
  models/        Earning, EarningDetail, WalletUpdate, Project
  screens/       Home, Earnings, EarningDetail, Projects   (UI only)
  controllers/   EarningsController, ProjectsController    (state + logic)
  constants/     colors/app_colors.dart (palette), themes/app_theme.dart (ThemeData)
  helpers/       http_helper (shared CRUD), projects_api (given fake API, as-is),
                 wallet_helper, api_exception, fake_backend (demo)
docs/
  part1_code_review.md          Part 1: ranked bug list, rewrite notes, guardrails
  part3_production_scenario.md  Part 3: founder message + investigation plan
```

- **`HttpHelper`**: every CRUD call (`get/post/put/delete`) goes through one class, which handles the timeout, status-code check and JSON decode, and throws a single `ApiException`. Controllers create an instance (`final HttpHelper _http = HttpHelper();`). All instances share one `http.Client` so connections are reused.
- **Controllers are created per route** with `Get.to(page, binding: ...)`. GetX deletes the controller when the route is popped, so `onClose` reliably cancels subscriptions and disposes the `ScrollController`.

## Part 2 – how the states work

| State | What you see | Driven by |
|---|---|---|
| First load | Full-screen spinner | `projects.isEmpty && isPageLoading` |
| First load failed | Full-screen message + Retry | `projects.isEmpty && pageError != null` |
| Loading next page | Spinner as the last list row | `isPageLoading` |
| Page failed | Red error row + Retry at the bottom, loaded items stay | `pageError != null` |
| End of list | "You've seen all projects" | `hasMore == false` (API returned an empty page) |
| Pull-to-refresh | Old list stays until page 0 arrives, then it's replaced. If the refresh fails, the old list stays and a snackbar shows | `refreshProjects()` |

Edge cases handled:
- Only one page request at a time.
- After a page error, scrolling does **not** retry automatically. The user taps Retry, so we don't hammer a failing server on every scroll event.
- A `_generation` counter makes a page request that was in flight when the user refreshed throw its result away. Otherwise old page N could get appended to the fresh page 0.

## Assumptions (and the question I'd have asked)

1. **Earning amounts are whole rupees (`int`).** *Q: Does the API send rupees or paise? Can amounts be negative, e.g. withdrawals or reversals?*
2. **The earnings API returns the full history in one response**, as the original code implies. *Q: Can the backend paginate `/earnings`? Downloading and decoding 3,000 entries on a cheap phone is wasteful when users mostly look at the latest 20. I'd paginate it the same way as Part 2.*
3. **The wallet stream sends new earnings only.** I dedupe by id and insert at the top. *Q: Can it also send updates to existing entries (pending → paid)? Then I'd replace by id instead of inserting.*
4. **The server list is the source of truth.** A wallet event that arrives during the initial fetch may be overwritten by the fetched list. *Q: Is that acceptable, or does the stream need a cursor/timestamp so we can merge reliably?*
5. **Detail opens after its data loads**, with a spinner on the tapped row. *Q: Would you rather open the detail screen immediately and load inside it? It feels faster but needs a loading state there too.*
6. **End of list = an empty page.** The fake API returns `[]` past page 7. *Q: Will the real API send `hasMore`/`total`? That would save one extra request at the end.*
7. **Pull-to-refresh keeps the old list visible while reloading** instead of clearing it, so a failed refresh never leaves a blank screen.
8. **I used GetX instead of async_redux.** It's what I know best, and the same principles (no side effects in build, lifecycle-bound subscriptions, explicit UI states) carry over directly.
