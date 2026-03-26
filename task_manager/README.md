# 📋 Task Manager — Flutter App

A clean, feature-rich Flutter task management app with SQLite local storage, smart search, draft saving, and dependency tracking.

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK ≥ 3.0.0
- Dart SDK ≥ 3.0.0
- Android Studio / VS Code with Flutter plugin

### Installation

```bash
# 1. Navigate to the project
cd task_manager

# 2. Install dependencies
flutter pub get

# 3. Run on a connected device or emulator
flutter run
```

> **Note:** The app uses custom Inter fonts listed in `pubspec.yaml`. If you don't have the font files, remove the `fonts:` section from `pubspec.yaml` and the app will fall back to the system font gracefully.

---

## ✅ Features Implemented

### Core Features
| Feature | Status |
| Create / Read / Update / Delete tasks | ✅ |
| Task title, description, due date, status | ✅ |
| Blocked By dependency (Task B blocked by Task A) | ✅ |
| Blocked tasks shown greyed-out / disabled | ✅ |
| Search tasks by title (auto-search while typing) | ✅ |
| Filter tasks by status | ✅ |
| Draft saving (restore mid-edit data) | ✅ |
| 2-second save delay with loading indicator | ✅ |
| Prevent double-tap on save | ✅ |
| SQLite local storage | ✅ |

### Bonus Features
| Feature | Status |
| Smart search with highlighted matches | ✅ |
| Progress bar (overall task completion) | ✅ |
| Swipe-to-delete with confirmation | ✅ |
| Overdue task detection + badge | ✅ |
| Task statistics pills (Total / To-Do / Active / Done) | ✅ |
| Animated FAB | ✅ |
| Empty state illustrations | ✅ |

---

### State Management
Uses **Provider** (`ChangeNotifier`) via `TaskProvider`:
- Holds the master task list in memory
- Applies search + filter reactively
- Exposes `isSaving` for UI lock during API calls
- `isTaskEffectivelyBlocked(task)` — checks if blocker task exists AND is not done

### Database
`DatabaseHelper` is a singleton wrapping **sqflite**:
- Auto-creates `tasks` table on first launch
- On task delete: clears `blocked_by_id` references in dependent tasks
- Full CRUD + search (LIKE query) + filter by status

### Draft Saving
`TaskFormScreen` uses **SharedPreferences** keyed per task:
- Key: `draft_task_new` for new tasks, `draft_task_edit_{id}` for edits
- Saves on every keystroke (title, description, date, status, blocked_by)
- On re-open: prompts user to **Restore** or **Discard** the draft
- Cleared after a successful save

### 2-Second Delay
In `TaskProvider.createTask()` and `updateTask()`:
```dart
await Future.delayed(const Duration(seconds: 2)); // Required delay
```
While saving, the UI shows:
- `LinearProgressIndicator` under the AppBar
- `CircularProgressIndicator` in the save button
- All form fields + button are disabled (`enabled: !_isSaving`)

---

## 📦 Dependencies

```yaml
sqflite: ^2.3.0          # SQLite local database
path: ^1.8.3             # Path joining for DB file
shared_preferences: ^2.2.2  # Draft persistence
provider: ^6.1.1         # State management
intl: ^0.19.0            # Date formatting
uuid: ^4.3.3             # Unique IDs (optional utility)
```

---

## 🧪 Example Workflow

1. **Create Task A** — "Design mockups", status: To-Do
2. **Create Task B** — "Build frontend", blocked by: Task A
3. Task B appears **greyed out** with a 🔒 lock badge
4. **Edit Task A** → change status to **Done**
5. Task B is now **unblocked** and fully interactive
6. **Search** "front" → "**front**end" is highlighted in purple
7. **Filter** by "In Progress" → only active tasks shown

---

## 🤔 Notes

- The Inter font is referenced in `pubspec.yaml` but font files are not included. Place `.ttf` files in `assets/fonts/` or remove the font declaration to use the system default.
- All data is stored locally — no internet connection required.
- Database file lives at the platform's default database path (managed by sqflite).
