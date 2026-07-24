# Wiring this into book-reader-app

## 1. Copy files
- `lib/data/local/services/bundled_content_seeder.dart` → same path in your repo
- `assets/data/bundled_books.json` → same path in your repo (fill in real IDs, see step 4)
- Put actual chapter images/audio (if any) under `assets/data/bundled_books/<bookId>/...`

## 2. pubspec.yaml — add the new asset paths explicitly
Flutter only auto-includes files that live *directly* inside a declared
folder, not nested subfolders, so add these two lines under `flutter: assets:`
even though `assets/` is already listed:

```yaml
flutter:
  assets:
    - .env
    - assets/
    - assets/data/
    - assets/data/bundled_books/
```
If you add nested chapter subfolders (e.g. `assets/data/bundled_books/book2/ch1/`),
list each of those folders too — same Flutter limitation.

## 3. lib/main.dart — run the seeder right after DB init, before AppBinding
```dart
import 'package:book_store/data/local/daos/book_dao.dart';
import 'package:book_store/data/local/services/bundled_content_seeder.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env', isOptional: true);
  } catch (_) {
    dotenv.loadFromString(envString: '');
  }
  AppConfig.validate();

  final db = await DatabaseHelper.instance.database;
  await BundledContentSeeder(BookDao(db)).seedIfNeeded();

  await AppBinding.init();

  runApp(const App());
}
```

## 4. Pick the book ID carefully — this is the important part
Use the **actual id of a real, published book** from book_store_admin for
your bundled book (not a made-up id). That's what makes this integrate
cleanly instead of becoming a permanent special case:

- `SyncManager.syncCatalog()` will see this book already exists locally and
  just refresh its title/order (`updateVersions: false` path in
  `_syncBookMetadata`) — your bundled chapter content is never overwritten.
- If you later edit that book's content in the admin panel and bump its
  version, the normal "update available" flow re-downloads only the changed
  chapters, same as any other book.
- The book shows up in the online catalog too, so there's no divergence
  between "the app's built-in copy" and "the server's copy" — they're the
  same book.

If you'd rather this be a book that ISN'T on your server at all (pure
in-app freebie, e.g. a short welcome story), that also works — just make
sure its id will never collide with a real server-issued book id.

## 5. Re-seed behavior after "clear app data"
No extra code needed: clearing app data wipes the SQLite DB, so the
`bundled_content_seeded_v1` flag is gone too, and the seeder runs again on
next launch — the user always lands back on an app with at least one full
book, offline, even right after a data wipe.

## 6. (Optional, separate from this) Android auto-backup for reinstall/new-device
This does NOT help with "clear app data" (Android skips backup for that
specific action) but does help with uninstall→reinstall or migrating to a
new phone. In `android/app/src/main/AndroidManifest.xml`:

```xml
<application
    android:allowBackup="true"
    android:fullBackupContent="@xml/backup_rules"
    ...>
```

`android/app/src/main/res/xml/backup_rules.xml`:
```xml
<?xml version="1.0" encoding="utf-8"?>
<full-backup-content>
    <include domain="database" path="."/>
    <include domain="file" path="downloads/"/>
</full-backup-content>
```
