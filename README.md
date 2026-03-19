# EzzeToDo 📝

A minimal, fast, and beautifully designed personal task manager built with Flutter.
Manage your daily tasks, track priorities, monitor productivity — all stored locally on your device.

---

## 📱 Screenshots

> Home Dashboard · Task List · Add Task · Stats · Settings

---

## ✨ Features

### 🏠 Home Dashboard
- Greeting based on time of day
- Circular progress banner showing overall completion rate
- Today's tasks at a glance
- High priority task highlights
- Quick stats (To Do / In Progress / Done)

### 📋 Task List
- Full task list with smart sorting (overdue first → priority → deadline)
- Filter by status: All / To Do / In Progress / Completed
- Filter by priority: All / High / Medium / Low
- Live search by title or description
- Swipe-friendly task cards with color-coded priority accent

### ➕ Add & Edit Tasks
- Task title and description
- Date picker for deadline
- Visual priority selector (🔴 High / 🟡 Medium / 🟢 Low)
- Status selector (○ To Do / ◑ In Progress / ● Completed)

### 📌 Task Detail
- Full task info view
- Deadline countdown (e.g. "3 days left", "Due today", "2 days overdue")
- Mark as complete
- Edit and delete actions

### 📊 Productivity Stats
- Completion rate percentage
- This week's completed count
- Total tasks and overdue count
- Progress bars by status
- Priority breakdown tiles
- 7-day bar chart
- Status distribution pie chart

### ⚙️ Settings
- 🌙 Dark / Light mode toggle (persisted across restarts)
- 📤 Export / backup tasks as shareable text
- 🗑️ Clear all tasks with confirmation
- Notification toggles (UI ready)
- App version info

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK `>=3.10.0`
- Dart SDK `>=3.0.0`
- Android Studio / VS Code with Flutter extension
- A connected device or emulator

### Installation
```bash
# 1. Clone the repository
git clone https://github.com/yourusername/ezzetodo.git
cd ezzetodo

# 2. Install dependencies
flutter pub get

# 3. Run the app
flutter run
```

### Build for Release
```bash
# Android APK
flutter build apk --release

# Android App Bundle (Play Store)
flutter build appbundle --release

# iOS (requires macOS + Xcode)
flutter build ios --release
```

---

## 🗂️ Project Structure
```
lib/
└── main.dart        ← Entire app in one file
    ├── Models       — Task, Priority, TaskStatus (Hive)
    ├── Adapters     — Hive type adapters (inline, no build_runner needed)
    ├── Theme        — AppColors, AppTheme (light + dark, Material 3)
    ├── Helpers      — Date formatting, color mapping utilities
    ├── Providers    — TaskProvider, ThemeProvider (Provider package)
    ├── Widgets      — TaskCard, Badges, FilterChips, StatBox, EmptyState
    └── Screens      — Home, TaskList, AddTask, TaskDetail, Stats, Settings
```

---

## 📦 Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `provider` | ^6.1.1 | State management |
| `hive` | ^2.2.3 | Local NoSQL database |
| `hive_flutter` | ^1.1.0 | Flutter integration for Hive |
| `uuid` | ^4.2.1 | Unique task ID generation |
| `intl` | ^0.18.1 | Date formatting |
| `fl_chart` | ^0.66.2 | Bar chart & pie chart |
| `share_plus` | ^7.2.1 | Export / share task backup |

---

## 🎨 Design System

### Color Palette

| Role | Color | Hex |
|------|-------|-----|
| Primary | Purple | `#534AB7` |
| High Priority | Red | `#E24B4A` |
| Medium Priority | Amber | `#BA7517` |
| Low Priority | Green | `#3B6D11` |
| To Do | Blue | `#378ADD` |
| Completed | Green | `#3B6D11` |

### Theme
- **Material 3** design system
- Full **light and dark** theme support
- Consistent 14px border radius on cards and inputs
- System default font throughout

---

## 🗺️ Roadmap

| Feature | Status |
|---------|--------|
| Core CRUD tasks | ✅ Done |
| Local Hive storage | ✅ Done |
| Dark / Light mode | ✅ Done |
| Priority & status filters | ✅ Done |
| Productivity charts | ✅ Done |
| Export / backup | ✅ Done |
| Local push notifications | 🔜 Planned |
| Calendar view | 🔜 Planned |
| Recurring tasks | 🔜 Planned |
| PDF export | 🔜 Planned |
| Cloud sync (Firebase) | 🔜 Planned |
| Tags / Labels | 🔜 Planned |

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Commit your changes: `git commit -m 'Add your feature'`
4. Push to the branch: `git push origin feature/your-feature`
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License.
```
MIT License

Copyright (c) 2026 EzzeToDo

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## 👨‍💻 MD. Imran Hasan

Built with ❤️ using Flutter

> *"Stay focused. Stay productive. Ezze does the rest."*
