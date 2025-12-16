# kwizzi - Entwicklungsrichtlinien

## Verbindliche Coding-Standards

Diese Richtlinien sind **zwingend** für die gesamte Entwicklung des kwizzi-Projekts einzuhalten.

---

## 0. 🔄 Wiederverwendbare Widgets

**REGEL:** **VOR** dem Erstellen neuer UI-Elemente **IMMER** nach existierenden Widgets in `lib/core/widgets/` suchen!

### ⚠️ Problem:
Viele Widgets werden in den einzelnen Screens **immer wieder neu implementiert**, obwohl sie bereits als wiederverwendbare Komponenten existieren. Das führt zu:
- ❌ Code-Duplizierung
- ❌ Inkonsistentem Design
- ❌ Mehrfachem Wartungsaufwand
- ❌ Platform-Inkonformitäten (iOS/Android unterscheiden sich)

### ✅ Lösung: Widget-Library durchsuchen!

**Vor dem Erstellen eines UI-Elements:**

1. **Prüfe `lib/core/widgets/` auf existierende Widgets:**
   ```bash
   # Alle verfügbaren Widgets anzeigen
   ls -la lib/core/widgets/
   
   # Nach Keyword suchen
   grep -r "Switch" lib/core/widgets/
   grep -r "Button" lib/core/widgets/
   grep -r "Card" lib/core/widgets/
   ```

2. **Häufige wiederverwendbare Widgets:**

   | Widget | Pfad | Verwendung |
   |--------|------|------------|
   | `AppSwitch` | `lib/core/widgets/app_switch.dart` | OS-konforme Switches (iOS: CupertinoSwitch, Android: Material Switch) |
   | `PlatformRadio` | `lib/core/widgets/platform_radio.dart` | Radio-Buttons (iOS: Cupertino, Android: Material) |
   | `PrimaryButton` | `lib/core/widgets/primary_button.dart` | Primäre Action-Buttons mit Haptic Feedback |
   | `GhostButton` | `lib/core/widgets/ghost_button.dart` | Sekundäre/Outline-Buttons mit Haptic Feedback |
   | `SquareCard` | `lib/core/widgets/square_card.dart` | Quadratische Karten mit Icon + Scale-Animation |
   | `HorizontalCard` | `lib/core/widgets/horizontal_card.dart` | Horizontale Karten mit Icon |
   | `BackgroundScaffold` | `lib/core/widgets/background_scaffold.dart` | Scaffold mit Hintergrundbild + Gradient |
   | `LogoAppBar` | `lib/core/widgets/logo_app_bar.dart` | AppBar mit Logo + Scroll-Verhalten |
   | `Skeleton` | `lib/core/widgets/skeleton.dart` | Loading Placeholders (Rectangle, Circle, Text) |
   | `Shimmer` | `lib/core/widgets/shimmer.dart` | Shimmer-Effekt für Skeletons |
   | `ProgressiveImage` | `lib/core/widgets/progressive_image.dart` | Bilder mit Fade-In + Error-Handling |

3. **Widget-Dokumentation lesen:**
   ```dart
   // Jedes Widget hat eine Dokumentation am Dateianfang
   // Beispiel: lib/core/widgets/app_switch.dart
   
   /// Wiederverwendbarer Switch mit Riverpod State Management
   /// Verwendet CupertinoSwitch auf iOS, Material Switch auf anderen Plattformen
   class AppSwitch extends ConsumerWidget {
     // ...
   }
   ```

### 📱 Platform Detection - WICHTIG!

**REGEL:** Verwende **IMMER** `PlatformHelper.isIOS` statt `Platform.isIOS`!

❌ **FALSCH:**
```dart
import 'dart:io';

if (Platform.isIOS) {  // ❌ NICHT SO!
  // iOS-spezifischer Code
}
```

✅ **RICHTIG:**
```dart
import '../utils/platform_helper.dart';

if (PlatformHelper.isIOS) {  // ✅ SO!
  // iOS-spezifischer Code
}
```

**Warum?**
- `Platform.isIOS` funktioniert nicht auf Web
- `PlatformHelper.isIOS` prüft `defaultTargetPlatform` und ist web-kompatibel
- Konsistente Plattform-Erkennung in der gesamten App

### ❌ Häufige Fehler:

**FALSCH - Manueller Switch in Screen:**
```dart
// ❌ NICHT SO! Switch wird direkt im Screen implementiert
SwitchListTile(
  value: isDarkMode,
  onChanged: (value) {
    // ...
  },
)
```

**RICHTIG - Wiederverwendbares Widget:**
```dart
// ✅ SO! AppSwitch oder ListTile + Platform-Switch verwenden
ListTile(
  title: Text('Dark Mode'),
  trailing: PlatformHelper.isIOS
      ? CupertinoSwitch(value: isDarkMode, onChanged: handleChange)
      : Switch(value: isDarkMode, onChanged: handleChange),
)

// ODER wenn StateProvider vorhanden:
AppSwitch(
  provider: myStateProvider,
  label: 'Dark Mode',
  onChanged: (value) { /* ... */ },
)
```

### 🔍 Recherche-Workflow:

**Bevor du UI-Code schreibst:**

1. **Frage dich:** "Gibt es das schon?"
2. **Suche in `lib/core/widgets/`** nach ähnlichen Komponenten
3. **Prüfe existierende Screens** auf Verwendung (z.B. SettingsPage)
4. **Wiederverwendbares Widget gefunden?** → Nutzen!
5. **Kein Widget gefunden?** → Prüfe ob es generisch genug ist:
   - Wird es an 2+ Stellen gebraucht? → Neues Widget in `lib/core/widgets/` erstellen
   - Nur 1x gebraucht? → Kann inline im Screen bleiben

### 📝 Checkliste:

Vor dem Commit:
- [ ] **Habe ich `lib/core/widgets/` durchsucht?**
- [ ] **Gibt es bereits ein Widget für meinen Use-Case?**
- [ ] **Verwende ich Platform-spezifische Widgets wo nötig?** (iOS ≠ Android)
- [ ] **Ist mein neues Widget wiederverwendbar genug?** (→ `lib/core/widgets/`)
- [ ] **Habe ich duplizierter Code vermieden?**

### 🎯 Ziel:
**DRY (Don't Repeat Yourself) - Jedes UI-Element nur 1x implementieren!**

---

## 1. 🧭 Navigation mit GoRouter

**REGEL:** Für alle Navigation **MUSS** `go_router` verwendet werden.

### Setup:
```yaml
dependencies:
  go_router: ^14.0.0  # oder aktuellere Version
```

### Implementierung:
```dart
import 'package:go_router/go_router.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/quiz/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return QuizPage(id: id);
      },
    ),
  ],
);

// In main.dart
MaterialApp.router(
  routerConfig: router,
  // ...
);
```

### Navigation:
```dart
// Navigieren
context.go('/quiz/123');        // Replace
context.push('/settings');      // Push

// Zurück
context.pop();                  // Zurück navigieren
```

**Wichtig:** Keine `Navigator.push()` oder `Navigator.pop()` verwenden!

---

## 2. 🎨 AppBar & Logo

**REGEL:** Jeder neue Screen **MUSS** das Logo in der AppBar haben.

### Logo-zu-Titel Verhalten beim Scrollen:
**Standard-Pattern:** Beim Scrollen wird das Logo ausgeblendet und der Titel eingeblendet.

```dart
import '../../../../core/widgets/logo_app_bar.dart';

class MeinScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<MeinScreen> createState() => _MeinScreenState();
}

class _MeinScreenState extends ConsumerState<MeinScreen> {
  final _scrollController = ScrollController();
  final _showTitleProvider = StateProvider<bool>((ref) => false);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final showTitle = _scrollController.offset > 50; // Ab 50px Scroll-Offset
    if (showTitle != ref.read(_showTitleProvider)) {
      ref.read(_showTitleProvider.notifier).state = showTitle;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showTitle = ref.watch(_showTitleProvider);
    
    return BackgroundScaffold(
      appBar: LogoAppBar(
        title: showTitle ? 'Mein Titel' : null, // Titel nur beim Scrollen
      ),
      body: SingleChildScrollView(
        controller: _scrollController, // WICHTIG: Controller zuweisen!
        child: // ...
      ),
    );
  }
}
```

### Einfache Verwendung (ohne Scroll-Verhalten):
```dart
import '../../../../core/widgets/logo_app_bar.dart';

class MeinScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: LogoAppBar(), // Nur Logo, kein Titel
      body: // ...
    );
  }
}
```

### Optional:
```dart
// Mit Actions (rechte Seite)
appBar: LogoAppBar(
  actions: [
    IconButton(
      icon: Icon(Icons.settings),
      onPressed: () {},
    ),
  ],
),

// Mit Leading (linke Seite)
appBar: LogoAppBar(
  leading: IconButton(
    icon: Icon(Icons.menu),
    onPressed: () {},
  ),
),

// Custom Logo-Höhe
appBar: LogoAppBar(logoHeight: 35),

// Fester Titel (ohne Logo-Übergang)
appBar: LogoAppBar(title: 'Fester Titel'),
```

### Back Button - Platform-spezifisch:
**WICHTIG:** Back Buttons **MÜSSEN** plattformspezifische Icons verwenden!

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ✅ RICHTIG - Platform-spezifisches Back Icon
appBar: LogoAppBar(
  leading: IconButton(
    icon: Icon(
      Platform.isIOS 
        ? Icons.arrow_back_ios  // iOS: Pfeil nach links mit Tail
        : Icons.arrow_back,      // Android: Einfacher Pfeil
    ),
    onPressed: () => context.pop(),
  ),
),

// ❌ FALSCH - Immer dasselbe Icon
appBar: LogoAppBar(
  leading: IconButton(
    icon: Icon(Icons.arrow_back), // NICHT plattformspezifisch!
    onPressed: () => context.pop(),
  ),
),
```

**Automatischer Back Button:**
```dart
// GoRouter zeigt automatisch den richtigen Back Button an
// wenn es eine vorherige Route gibt
appBar: LogoAppBar(), // Kein leading nötig!
```

**Icons für verschiedene Plattformen:**
| Plattform | Icon | Konstante |
|-----------|------|-----------|
| iOS | ‹ | `Icons.arrow_back_ios` oder `Icons.arrow_back_ios_new` |
| Android | ← | `Icons.arrow_back` |
| Material Design 3 | ← | `Icons.arrow_back` |

---

## 3. 🚫 Deprecated Code

**REGEL:** Deprecated Code ist **VERBOTEN**!

### ❌ NICHT erlaubt:
```dart
// FALSCH - withOpacity ist deprecated!
color.withOpacity(0.5)
```

### ✅ STATTDESSEN verwenden:
```dart
// RICHTIG - withAlpha verwenden!
color.withAlpha((255 * 0.5).toInt())  // für 50% Transparenz
color.withAlpha(128)                   // direkt mit Alpha-Wert (0-255)
```

### Umrechnungstabelle Opacity → Alpha:
| Opacity | Alpha (0-255) | Berechnung |
|---------|---------------|------------|
| 0.0     | 0             | 255 × 0.0  |
| 0.1     | 26            | 255 × 0.1  |
| 0.2     | 51            | 255 × 0.2  |
| 0.3     | 77            | 255 × 0.3  |
| 0.4     | 102           | 255 × 0.4  |
| 0.5     | 128           | 255 × 0.5  |
| 0.6     | 153           | 255 × 0.6  |
| 0.7     | 179           | 255 × 0.7  |
| 0.8     | 204           | 255 × 0.8  |
| 0.9     | 230           | 255 × 0.9  |
| 1.0     | 255           | 255 × 1.0  |

**Weitere deprecated APIs prüfen:**
- Immer auf Flutter Lint-Warnings achten
- Bei Deprecated-Warnung: Sofort durch moderne Alternative ersetzen

---

## 3.1 📦 Dependencies: NUR Stabile Versionen

**REGEL:** Es dürfen **NUR stabile (stable) Package-Versionen** verwendet werden!

### ❌ VERBOTEN:
```yaml
dependencies:
  my_package: ^3.0.0-beta.1    # ❌ Beta-Version
  other_package: ^2.5.0-alpha  # ❌ Alpha-Version
  test_package: ^1.0.0-dev.3   # ❌ Dev-Version
  experimental: ^0.0.1-rc.2    # ❌ Release Candidate
```

### ✅ ERLAUBT:
```yaml
dependencies:
  my_package: ^2.2.1           # ✅ Stabile Version
  other_package: ^2.4.0        # ✅ Stabile Version
  test_package: ^0.9.5         # ✅ Stabile Version
```

### Warum?
- **Stabilität:** Beta/Alpha-Versionen können Breaking Changes haben
- **Wartbarkeit:** Stabiles API = weniger Refactoring
- **Produktionsreife:** Nur getestete Packages in Production
- **Zuverlässigkeit:** Weniger Bugs und unerwartetes Verhalten

### Ausnahmen:
- **Nur wenn absolut notwendig** und nach Rücksprache
- Muss ausdrücklich dokumentiert werden
- Package-Maintainer muss aktiv sein

### Genehmigte Ausnahmen:
```yaml
dependencies:
  flutter_html: ^3.0.0-beta.2  # ✅ AUSNAHME: Keine stabile Version für Flutter 3.x verfügbar
```

### Prüfen vor Installation:
```bash
# Auf pub.dev prüfen ob stabile Version verfügbar ist
flutter pub outdated

# Immer die neueste STABILE Version wählen
flutter pub add package_name  # nimmt automatisch stabile Version
```

---

## 3.2 🎬 Hero-Animationen für nahtlose Übergänge

**REGEL:** Bei Navigation zwischen Screens **SOLL** Hero-Animation für gemeinsame Elemente verwendet werden.

### Wann Hero-Animationen verwenden?

**✅ Empfohlen für:**
- Logo zwischen verschiedenen Screens
- Icons die zu Detail-Seiten führen (z.B. Settings-Icon → Settings-Page)
- Karten/Cards die sich zu Detail-Ansichten öffnen
- Formular-Felder die zwischen verwandten Screens geteilt werden
- Avatare/Profilbilder
- Kategorie-Icons zu Quiz-Screens

**❌ NICHT verwenden für:**
- Elemente die sich stark in Größe/Form ändern (kann unnatürlich wirken)
- Wenn mehr als ~5 Hero-Animationen gleichzeitig laufen würden
- Bei komplexen Layouts mit vielen animierten Elementen

### Implementierung:

#### Logo in AppBar (Standard-Pattern):
```dart
// In LogoAppBar - heroTag ist optional
appBar: LogoAppBar(
  heroTag: 'app_logo',  // Macht Logo zwischen Screens animiert
  title: showTitle ? 'Mein Titel' : null,
),
```

#### Icon-Button zu Detail-Screen:
```dart
// Source Screen (z.B. HomePage)
Hero(
  tag: 'settings_icon',
  child: IconButton(
    icon: const Icon(Icons.settings_outlined),
    onPressed: () => context.push('/settings'),
  ),
),

// Target Screen (z.B. SettingsPage)
// Hero-Icon im Header anzeigen
Hero(
  tag: 'settings_icon',
  child: Container(
    width: 80,
    height: 80,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primary.withAlpha(38),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Icon(
      Icons.settings_outlined,
      size: 40,
      color: Theme.of(context).colorScheme.primary,
    ),
  ),
),
```

#### Karten/Cards mit Icons:
```dart
// Card Widget mit optionalem heroTag Parameter
SquareCard(
  title: 'Einzelspieler',
  icon: Icons.person,
  heroTag: 'game_mode_single_play',  // Optional
  onTap: () => context.push('/static/mode_single_play'),
),

// Auf Zielseite: Icon am Anfang anzeigen
final String? heroTag = _getHeroTag(widget.contentKey);
final IconData? heroIcon = _getHeroIcon(widget.contentKey);

if (heroTag != null && heroIcon != null)
  Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Hero(
      tag: heroTag,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: heroColor?.withAlpha(38),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(heroIcon, size: 64, color: heroColor),
      ),
    ),
  ),
```

#### Form-Fields zwischen Auth-Screens:
```dart
// Wichtig: Material-Wrapper um Flicker zu vermeiden!
Hero(
  tag: authMethod == AuthMethod.email ? 'auth_email_field' : 'auth_phone_field',
  child: Material(
    type: MaterialType.transparency,
    child: AppEmailField(
      controller: _emailController,
      // ...
    ),
  ),
),
```

### Hero-Tag Naming Convention:

**Präfix-basierte Namen:**
- `app_logo` - App-Logo in der AppBar
- `settings_icon` - Settings-Icon
- `game_mode_{name}` - Spielmodi-Icons (z.B. `game_mode_single_play`)
- `auth_email_field` / `auth_phone_field` - Auth-Formular-Felder
- `auth_password_field` - Passwort-Feld
- `profile_avatar` - Benutzer-Avatar
- `category_{id}` - Kategorie-Icons

**Wichtig:**
- Hero-Tags müssen **eindeutig** pro Screen sein
- Gleiches Tag auf Source und Target Screen verwenden
- Tags sollten **beschreibend** sein

### OS-Konformität:

Hero-Animationen sind **automatisch OS-konform**:
- **iOS**: ease-in-out Kurve, ~350ms Duration
- **Android**: fast-out-slow-in Kurve, ~300ms Duration

Flutter passt die Animation automatisch an die Plattform an - keine manuelle Konfiguration nötig!

### Best Practices:

```dart
// ✅ RICHTIG - Material-Wrapper für TextField-Widgets
Hero(
  tag: 'my_field',
  child: Material(
    type: MaterialType.transparency,
    child: AppEmailField(...),
  ),
),

// ✅ RICHTIG - Optional heroTag in wiederverwendbaren Widgets
class SquareCard extends StatelessWidget {
  final String? heroTag;  // Optional!
  
  const SquareCard({
    this.heroTag,
    // ...
  });
  
  @override
  Widget build(BuildContext context) {
    final iconWidget = Container(/* icon */);
    
    return heroTag != null
      ? Hero(tag: heroTag!, child: iconWidget)
      : iconWidget;
  }
}

// ❌ FALSCH - Doppelte Hero-Tags
Hero(tag: 'icon', child: Icon(Icons.star))  // Screen 1
Hero(tag: 'icon', child: Icon(Icons.star))  // Screen 1 - KONFLIKT!

// ❌ FALSCH - Hero ohne Material bei TextField
Hero(
  tag: 'field',
  child: TextField(...),  // Kann zu Flicker führen!
),
```

### Debugging:

```dart
// Hero-Animationen im Debug-Modus visualisieren
MaterialApp(
  debugShowCheckedModeBanner: false,
  showPerformanceOverlay: false,
  checkerboardRasterCacheImages: false,
  // ...
);

// Bei Problemen: Hero-Animation deaktivieren zum Testen
// Hero-Tag einfach auf null setzen
heroTag: null,  // Temporär zum Debuggen
```

---

## 4. 🔄 State Management mit Riverpod

**REGEL:** `setState()` ist **VERBOTEN**! Stattdessen **NUR Riverpod** verwenden.

### Setup:
Stelle sicher, dass Riverpod installiert ist:
```yaml
dependencies:
  flutter_riverpod: ^2.4.0  # oder aktuellere Version
```

### ❌ NICHT erlaubt:
```dart
class MeinWidget extends StatefulWidget {
  @override
  State<MeinWidget> createState() => _MeinWidgetState();
}

class _MeinWidgetState extends State<MeinWidget> {
  int counter = 0;
  
  void increment() {
    setState(() {  // ❌ VERBOTEN!
      counter++;
    });
  }
}
```

### ✅ STATTDESSEN verwenden:

#### Option A: StateProvider (für einfache Werte)
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider definieren
final counterProvider = StateProvider<int>((ref) => 0);

// Widget verwenden
class MeinWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counter = ref.watch(counterProvider);
    
    return ElevatedButton(
      onPressed: () => ref.read(counterProvider.notifier).state++,
      child: Text('Counter: $counter'),
    );
  }
}
```

#### Option B: NotifierProvider (für komplexere Logik)
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Notifier-Klasse
class CounterNotifier extends Notifier<int> {
  @override
  int build() => 0;
  
  void increment() => state++;
  void decrement() => state--;
  void reset() => state = 0;
}

// Provider
final counterProvider = NotifierProvider<CounterNotifier, int>(
  CounterNotifier.new,
);

// Widget
class MeinWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counter = ref.watch(counterProvider);
    final notifier = ref.read(counterProvider.notifier);
    
    return Column(
      children: [
        Text('Counter: $counter'),
        ElevatedButton(
          onPressed: notifier.increment,
          child: Text('Increment'),
        ),
      ],
    );
  }
}
```

#### Option C: AsyncNotifierProvider (für asynchrone Daten)
```dart
class QuizNotifier extends AsyncNotifier<List<Question>> {
  @override
  Future<List<Question>> build() async {
    return await fetchQuestions();
  }
  
  Future<void> loadMore() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return await fetchQuestions();
    });
  }
}

final quizProvider = AsyncNotifierProvider<QuizNotifier, List<Question>>(
  QuizNotifier.new,
);
```

### Widget-Typen für Riverpod:
- **ConsumerWidget**: Ersatz für StatelessWidget
- **ConsumerStatefulWidget**: Nur wenn wirklich nötig (z.B. für Controller)
- **Consumer**: Für lokale Rebuilds innerhalb eines Widgets

### Main.dart Setup:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    const ProviderScope(  // WICHTIG: App in ProviderScope wrappen!
      child: MainApp(),
    ),
  );
}
```

---

## 5. 📱 Responsive Layout

**REGEL:** Alle Screens **MÜSSEN** responsive sein und sich an verschiedene Bildschirmgrößen anpassen.

### Breakpoints:
```dart
// core/constants/breakpoints.dart
class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
}
```

### ✅ Responsive Implementierung:

#### MediaQuery für Breakpoints:
```dart
class ResponsiveWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < Breakpoints.mobile) {
      return MobileLayout();
    } else if (width < Breakpoints.tablet) {
      return TabletLayout();
    } else {
      return DesktopLayout();
    }
  }
}
```

#### LayoutBuilder für flexible Layouts:
```dart
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth < Breakpoints.mobile) {
      return SingleChildScrollView(
        child: Column(children: widgets),
      );
    } else {
      return Row(
        children: widgets.map((w) => Expanded(child: w)).toList(),
      );
    }
  },
)
```

#### Responsive Padding & Spacing:
```dart
// Anstatt feste Werte:
padding: const EdgeInsets.all(16),  // ❌ NICHT responsive

// Besser:
padding: EdgeInsets.symmetric(
  horizontal: width < Breakpoints.mobile ? 16 : 32,
  vertical: 16,
),  // ✅ Responsive
```

#### Flexible Font Sizes:
```dart
// Helper-Funktion erstellen:
double getResponsiveFontSize(BuildContext context, double baseSize) {
  final width = MediaQuery.of(context).size.width;
  if (width < Breakpoints.mobile) return baseSize;
  if (width < Breakpoints.tablet) return baseSize * 1.1;
  return baseSize * 1.2;
}

// Verwendung:
Text(
  'Titel',
  style: TextStyle(
    fontSize: getResponsiveFontSize(context, 24),
  ),
)
```

#### Grid Layouts:
```dart
// Responsive Columns
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: width < Breakpoints.mobile ? 1 
                  : width < Breakpoints.tablet ? 2 
                  : 3,
    crossAxisSpacing: 16,
    mainAxisSpacing: 16,
  ),
  itemBuilder: (context, index) => YourWidget(),
)
```

---

## 6. 🎨 Platform-spezifisches Design

**REGEL:** Design-Entscheidungen **MÜSSEN** den Plattform-Guidelines entsprechen.

### Border Radius (Rundungen):

#### iOS (Cupertino):
```dart
// iOS verwendet größere, weichere Rundungen
BorderRadius.circular(12)  // Buttons, Cards
BorderRadius.circular(20)  // Modals, Bottom Sheets
```

#### Android (Material):
```dart
// Material Design 3
BorderRadius.circular(12)  // Small components
BorderRadius.circular(16)  // Medium components (Cards)
BorderRadius.circular(28)  // Large components (FAB)
```

#### Plattform-Detection:
```dart
import 'dart:io' show Platform;

double getBorderRadius() {
  if (Platform.isIOS) {
    return 12.0;
  } else {
    return 16.0;  // Android
  }
}
```

### Farben & Kontraste:

#### Material Design 3 (Android):
```dart
// Verwende ColorScheme aus Theme
final colorScheme = Theme.of(context).colorScheme;

Container(
  color: colorScheme.primaryContainer,
  child: Text(
    'Text',
    style: TextStyle(color: colorScheme.onPrimaryContainer),
  ),
)
```

#### iOS Cupertino:
```dart
import 'package:flutter/cupertino.dart';

CupertinoTheme.of(context).primaryColor
CupertinoColors.systemGrey
CupertinoColors.systemBackground
```

#### Plattform-adaptive Farben:
```dart
Color getPlatformColor(BuildContext context) {
  if (Platform.isIOS) {
    return CupertinoColors.activeBlue;
  } else {
    return Theme.of(context).colorScheme.primary;
  }
}
```

### Elevation & Shadows:

#### Material (Android):
```dart
// Material verwendet Elevation
Card(
  elevation: 2,  // Leichter Schatten
  child: Content(),
)

Container(
  decoration: BoxDecoration(
    boxShadow: [
      BoxShadow(
        color: Colors.black.withAlpha(26),  // 10% opacity
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  ),
)
```

#### iOS (Cupertino):
```dart
// iOS verwendet subtilere Schatten
Container(
  decoration: BoxDecoration(
    boxShadow: [
      BoxShadow(
        color: Colors.black.withAlpha(13),  // 5% opacity
        blurRadius: 10,
        offset: const Offset(0, 2),
      ),
    ],
  ),
)
```

### Navigation & Transitions:

#### Platform-adaptive Widgets:
```dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

Widget buildPlatformButton(String text, VoidCallback onPressed) {
  if (Platform.isIOS) {
    return CupertinoButton.filled(
      onPressed: onPressed,
      child: Text(text),
    );
  } else {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }
}
```

### Standard-Werte nach Plattform:

| Element | iOS | Android |
|---------|-----|---------|
| Border Radius (Small) | 8-10 | 8-12 |
| Border Radius (Medium) | 12-14 | 12-16 |
| Border Radius (Large) | 16-20 | 20-28 |
| Padding (Standard) | 16 | 16 |
| Padding (Large) | 20-24 | 24 |
| Shadow Opacity | 5-10% | 10-15% |
| Shadow Blur | 8-12 | 8-16 |

---

## 7. 🖼️ Hintergrundbild

**REGEL:** Alle Screens **MÜSSEN** das `BackgroundScaffold` Widget verwenden.

### Verwendung:
```dart
import '../../../../core/widgets/background_scaffold.dart';

class MeinScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BackgroundScaffold(
      appBar: LogoAppBar(),  // Logo-AppBar kombiniert mit Background
      body: // Dein Content hier
    );
  }
}
```

### Eigenschaften:
- **Hintergrundbild:** `assets/background/background.png`
- **Bildschirmfüllend:** `fit: BoxFit.cover`
- **Theme-abhängige Transparenz:**
  - Light Mode: 80% weiße Overlay (Alpha 204)
  - Dark Mode: 70% schwarze Overlay (Alpha 179)

### Vorteile:
- Konsistentes Design über alle Screens
- Automatische Theme-Anpassung
- Lesbarkeit durch Overlay-Schicht garantiert
- Alle Standard-Scaffold-Features verfügbar

### Vollständiges Beispiel:
```dart
return BackgroundScaffold(
  appBar: LogoAppBar(
    actions: [
      IconButton(
        icon: Icon(Icons.settings),
        onPressed: () {},
      ),
    ],
  ),
  body: Center(
    child: Text('Mein Content'),
  ),
  floatingActionButton: FloatingActionButton(
    onPressed: () {},
    child: Icon(Icons.add),
  ),
);
```

### Assets-Setup:
In `pubspec.yaml`:
```yaml
flutter:
  assets:
    - assets/background/
```

---

## 8. 🌍 Internationalisierung (i18n)

**REGEL:** Alle Texte **MÜSSEN** über `easy_localization` internationalisiert werden. KEINE hardcodierten Texte!

### Setup:
```yaml
dependencies:
  easy_localization: ^3.0.7

flutter:
  assets:
    - assets/translations/
```

### Unterstützte Sprachen:
- Deutsch (`de`)
- Englisch (`en`)

### Main.dart Setup:
```dart
import 'package:easy_localization/easy_localization.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('de'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('de'),
      child: const ProviderScope(
        child: MainApp(),
      ),
    ),
  );
}

// In MaterialApp:
return MaterialApp(
  localizationsDelegates: context.localizationDelegates,
  supportedLocales: context.supportedLocales,
  locale: context.locale,
  // ...
);
```

### ❌ NICHT erlaubt:
```dart
Text('Willkommen bei kwizzi!')  // ❌ Hardcodierter Text
const Text('Login required')      // ❌ Hardcodierter Text
```

### ✅ RICHTIG:
```dart
Text('home.welcome'.tr())              // ✅ Lokalisiert
Text('common.login_required'.tr())     // ✅ Lokalisiert
```

### Translation Files:
**Struktur:** `assets/translations/{locale}.json`

**Beispiel `de.json`:**
```json
{
  "home": {
    "welcome": "Willkommen bei kwizzi!",
    "categories": "Kategorien"
  },
  "common": {
    "login_required": "Anmeldung erforderlich"
  }
}
```

**Beispiel `en.json`:**
```json
{
  "home": {
    "welcome": "Welcome to kwizzi!",
    "categories": "Categories"
  },
  "common": {
    "login_required": "Login required"
  }
}
```

### Mit Parametern:
```dart
// Translation file:
"quiz.points": "{current}/{total} Punkten"

// Verwendung:
Text('quiz.points'.tr(namedArgs: {'current': '8', 'total': '10'}))
// Ergebnis: "8/10 Punkten"
```

### Best Practices:
- Namespaces verwenden (`home.`, `quiz.`, `common.`)
- Konsistente Schlüsselnamen
- Beide Sprachen immer synchron halten
- Platzhalter mit `{}` für dynamische Werte

---

## 9. ✅ Syntax-Prüfung

**REGEL:** Vor jedem Commit **MÜSSEN** alle Syntaxfehler behoben sein!

### Prüfung durchführen:
```bash
# Flutter Analyze ausführen
flutter analyze

# Oder in VS Code:
# Problems Panel öffnen (Cmd/Ctrl + Shift + M)
```

### Häufige Fehler:

**❌ IconData statt Icon Widget:**
```dart
// FALSCH
AppTextField(
  prefixIcon: Icons.person_outline,  // ❌ IconData
)

// RICHTIG
AppTextField(
  prefixIcon: const Icon(Icons.person_outline),  // ✅ Icon Widget
)
```

**❌ Nicht existierende Parameter:**
```dart
// FALSCH
AppTextField(
  autoValidate: true,  // ❌ Parameter existiert nicht
)

// RICHTIG - Parameter weglassen oder korrekte Schreibweise prüfen
AppTextField(
  // Kein autoValidate Parameter
)
```

**❌ Typ-Fehler:**
```dart
// FALSCH
String name = 123;  // ❌ int kann nicht zu String zugewiesen werden

// RICHTIG
String name = '123';  // ✅ String
// oder
String name = 123.toString();  // ✅ Konvertierung
```

### Vor jedem Commit:
1. **VS Code Problems Panel prüfen** (keine roten Fehler!)
2. **`flutter analyze` ausführen** (muss mit 0 issues beenden)
3. **Keine Deprecated Warnings ignorieren**
4. **Type-Safety beachten** (keine `dynamic` ohne Grund)

### Automatische Checks:
```yaml
# analysis_options.yaml sollte strikt sein
analyzer:
  strong-mode:
    implicit-casts: false
    implicit-dynamic: false
```

---

## 📋 Checkliste vor jedem Commit

- [ ] **✅ Keine Syntaxfehler** (`flutter analyze` erfolgreich)
- [ ] **✅ Keine Compiler-Errors** (Problems Panel leer)
- [ ] Logo in AppBar bei neuen Screens?
- [ ] **BackgroundScaffold statt Scaffold verwendet?**
- [ ] Kein `withOpacity()` verwendet?
- [ ] Kein `setState()` verwendet?
- [ ] Alle Riverpod Provider korrekt definiert?
- [ ] `ProviderScope` in main.dart?
- [ ] Keine Deprecated-Warnings im Code?
- [ ] **Responsive Layout getestet** (Mobile, Tablet, Desktop)?
- [ ] **Platform-spezifische Radien** verwendet?
- [ ] **ColorScheme aus Theme** genutzt?
- [ ] **Plattform-Guidelines** beachtet?
- [ ] **KEINE hardcodierten Texte** - alle mit `.tr()` lokalisiert?
- [ ] **Beide Sprachen (de/en)** in Translation-Files vorhanden?

---

## 🔍 Code Review Kriterien

Pull Requests werden abgelehnt, wenn:
1. ❌ **Syntaxfehler oder Compiler-Errors vorhanden sind**
2. ❌ **`flutter analyze` mit Fehlern beendet**
3. ❌ Logo fehlt in einem Screen mit AppBar
4. ❌ **`Scaffold` statt `BackgroundScaffold` verwendet wird**
5. ❌ `withOpacity()` oder andere deprecated APIs verwendet werden
6. ❌ `setState()` verwendet wird
7. ❌ Riverpod nicht korrekt implementiert ist
8. ❌ **Layout nicht responsive ist**
9. ❌ **Feste Werte statt Theme-Colors verwendet werden**
10. ❌ **Platform-Guidelines ignoriert werden**
11. ❌ **Hardcodierte Texte gefunden werden**
12. ❌ **Texte nicht in beiden Sprachen vorhanden sind**

---

**Letzte Aktualisierung:** 13. Dezember 2025
**Version:** 1.4
