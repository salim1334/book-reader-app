# Book Reader Mobile App

Flutter mobile reader app for the Book Store system. It now has a working local DB, remote sync layer, download manager, bottom navigation, and reader UI wired to the admin panel's mobile endpoints.

## What is implemented

- `lib/data/remote/` — `ApiClient` (Dio), `BookRemoteSource`, `ChapterRemoteSource`, `DownloadManager`, and `SyncManager`.
- `lib/data/local/` — SQLite schema, DAOs, and local models now use string CUIDs to match the admin panel.
- `lib/ui/screens/` — splash/onboarding flow, bottom tab navigation with `HomeScreen`, `DownloadsScreen`, `SettingsScreen`; `BookDetailsScreen` lists chapters; `ChapterReaderScreen` reads text, images, and plays downloaded audio.
- `lib/main.dart` — registers all services and initializes the sync manager.
- Admin panel mobile endpoints under `/api/mobile/*` are protected by a shared `MOBILE_API_KEY` and expose only published, non-hidden books.

## Quick start

1. In `admin_panel/.env` set:
   ```env
   MOBILE_API_KEY=your-shared-key
   ```
2. In `mobile_app/.env` set:
   ```env
   # For a physical device use your dev machine's LAN IP and keep the trailing slash.
   API_BASE_URL=http://192.168.1.100:3000/api/
   API_KEY=your-shared-key
   AUTHOR_ID=the-author-id-for-this-app
   APP_ENV=development
   ```
   Then copy `.env.example` to `.env` if you haven't already; the file is bundled as an asset, so it must exist before building.
3. Start the admin panel (`npm run dev` or `next dev`).
4. Run the Flutter app:
   ```bash
   flutter pub get
   flutter run
   ```

## How it works

- On first launch the bundled book from `assets/data/first_book.json` is seeded into SQLite.
- On the **HomeScreen**, tap `+` to fetch the list of published books from the admin panel.
- Tap a remote book to download its metadata, chapter text, and media (images/audio) to the device.
- Tap a local book to see its chapters, and tap a chapter to read it.
- `TEXT` chapters are displayed as scrollable text with a bottom audio player when audio is downloaded.
- `IMAGE` chapters are displayed as a zoomable `PageView` over the downloaded image files.
- The **Downloads** tab shows the active download queue with retry for failed chapters and lets you delete downloaded books.
- The app starts with a splash/onboarding flow on first launch.

## Key admin panel endpoints

- `GET /api/mobile/books?authorId=<id>` — list published books.
- `GET /api/mobile/books/<bookId>` — book details with chapter summaries.
- `GET /api/mobile/chapters/<chapterId>` — chapter metadata, pages/texts, and audio info.
- `GET /api/mobile/chapters/<chapterId>/pages` — pages/texts plus `audios` for media download.
- Static assets at `/uploads/images/<bookId>/<chapterId>/<file>` and `/uploads/audio/<bookId>/<chapterId>/<file>`.

## Next steps

- Add search/filter to `HomeScreen` and `DownloadsScreen`.
- Add richer media controls (playback speed, bookmarks, sleep timer).
- Add unit/widget tests for DAOs, sync manager, and UI flows.
