# signalplus

One static facade, `SignalPlus`, **receives** notifications and lets the signed-in user manage their own notification settings in SignalPlus. It talks only to the **SDK API** (`/sdk/v1`) with the environment's public **App ID**: no API key in the app and no proxy in your backend. Sending notifications is your backend's job and is not part of this package.

- `SignalPlus.init(SignalPlusConfig(appId: 'sdk_…', …))`: one call sets up Firebase, Android channels and the client, and registers the device.
- `SignalPlus.login(...)` / `SignalPlus.logout()` when the user signs in and out of the app.
- `SignalPlus.preferences()`, `topics()`, `subscribe(...)` and the rest: one function per thing the user does.
- `SignalPlus.onMessage`, `SignalPlus.onBackgroundMessage` and `SignalPlus.onNotificationTap`: each event is its own function.

Every operation returns `Either<ServiceFailure, T>` (fpdart) and never throws. A value that may be missing is an `Option<T>`. The event listeners return a `StreamSubscription`, and `dispose()` returns nothing.

## Contents

- [Installation](#installation)
- [Before you start](#before-you-start)
- [Quick start](#quick-start)
- [What the package does by itself](#what-the-package-does-by-itself)
- [Working with results](#working-with-results)
- [API reference](#api-reference)
  - [Setup](#setup): `init`, `dispose`, `isInitialized`
  - [Events](#events): `onMessage`, `onNotificationTap`, `onBackgroundMessage`
  - [Push](#push): `requestPermission`, `permission`, `token`, `deleteToken`, `clearNotifications`
  - [Device, language and sign-in](#device-language-and-sign-in): `setLocale`, `login`, `logout`, `installationId`, `externalId`
  - [Notification settings](#notification-settings): `preferences`, `updatePreferences`, `setQuietHours`, `clearQuietHours`
  - [Topics](#topics): `topics`, `recipientTopics`, `subscribe`, `unsubscribe`
  - [Categories](#categories): `categories`
  - [Opens](#opens): `reportOpened`
- [Your backend's part](#your-backends-part)
- [SignalPlusConfig](#signalplusconfig)
- [Types](#types)
- [Errors](#errors)
- [Message format](#message-format)
- [Platform setup](#platform-setup)
- [Typical flows](#typical-flows)
- [Limitations](#limitations)

---

## Installation

The package is not published to pub.dev. Depend on a git tag:

```yaml
dependencies:
  signalplus:
    git:
      url: https://github.com/abd-mtk/signalplus.git
      ref: v0.1.0
```

One import gives you everything:

```dart
import 'package:signalplus/signalplus.dart';
```

---

## Before you start

In the dashboard, open **Environment → App SDK**:

1. Copy the **App ID** (`sdk_…`). It is not a secret: it ships inside the app and only names the environment. It is **not** the environment id (`env_…`), which answers `401 AppIdInvalid`.
2. Create the **topics** users may follow on the environment's **Topics** screen. The app subscribes only to topics created there.

The device registers itself through the app; your backend may register it too, with the same installation id. Tags are set by your backend (Service API) and the dashboard; the app never reads or writes them.

---

## Quick start

```dart
import 'package:flutter/material.dart';
import 'package:signalplus/signalplus.dart';

@pragma('vm:entry-point')
Future<void> onBackground(final RemoteMessage message) async {
  // Runs in a separate isolate while the app is in the background or closed.
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SignalPlus.init(
    const SignalPlusConfig(
      appId: 'sdk_01J9…', // Environment → App SDK
      locale: ServiceLocale.ar, // the app's current language
    ),
  );

  SignalPlus.onMessage((final RemoteMessage message) => debugPrint('foreground ${message.messageId}'));
  SignalPlus.onNotificationTap((final NotificationPayload payload) => openScreen(payload.data));
  await SignalPlus.onBackgroundMessage(onBackground);
  await SignalPlus.categories(); // one Android channel per category, before anyone signs in

  runApp(const MyApp());
}

// After sign-in:
await SignalPlus.login(user.id);

// On sign-out:
await SignalPlus.logout();
```

---

## What the package does by itself

| What | How |
|---|---|
| **Firebase** | Reads `google-services.json` (Android) and `GoogleService-Info.plist` (iOS). You do not pass `DefaultFirebaseOptions.currentPlatform`. |
| **Registration** | After `init`, registers the device with its FCM token, permission, platform, app version and build, OS version, device model, IANA time zone and language. Turn it off with `registerOnStart: false`. |
| **Re-registration** | A new FCM token or a permission change registers the device again. A registration identical to the last one is not sent. |
| **Installation id** | A UUID v4 created once per install and kept in secure storage. It is the only thing that names this device to the SDK API: there is no device secret. A reinstall gets a new id. |
| **Recovery** | A device the service does not know (`InstallationNotFound`), for example before its first registration went through, is registered again under the same id and the call retried once. |
| **Signed-in user** | Every user function acts on the user signed in on this device; no function takes an id except `login`. The id is also kept locally for `externalId()`, and forgotten after `logout()` or a `NotSignedIn` answer. |
| **Reinstall** | On iOS the Keychain outlives the app. On the first launch of a new install, the package clears the saved id, user and background settings, so a reinstall is a new device. |
| **Opens** | A tap on a notification that carries a `NotifyId` reports `Opened` for this device. Repeating it changes nothing. |
| **Launch tap** | The tap that opened a closed app reaches `onNotificationTap` once, after the first frame, so the navigator is ready. |
| **Foreground display** | On Android, foreground messages are shown as local notifications on the channel of their category. On iOS, the system banner is used. |
| **Background display** | Data-only messages in the background or closed state are shown as local notifications, then passed to your `onBackgroundMessage` function. |
| **Images** | `notification.image` / `data['image']` are downloaded (10 s timeout, 5 MB cap) and attached. Keep them under 1 MB: that is FCM's own limit for `notification.image`. |
| **Language** | Nothing is detected or translated. The `locale` you pass to `init`, then to `setLocale`, is used for the device, the signed-in user and `Accept-Language`. |

---

## Working with results

Every call returns `Either<ServiceFailure, T>`: `Left` is a failure and `Right` is the value. Use `match`, or `fold`, `map`, `getOrElse` and the other fpdart helpers:

```dart
final Either<ServiceFailure, PreferencesEntity> result = await SignalPlus.preferences();

result.match(
  (final ServiceFailure failure) => showError(failure.message),
  (final PreferencesEntity preferences) => showSettings(preferences),
);

// Only the value, with a fallback:
final PushPermission permission = (await SignalPlus.permission()).getOrElse((_) => PushPermission.notDetermined);
```

Optional parameters and optional fields use `Option`: `Some(value)` or `None()`.

```dart
final Option<String> user = (await SignalPlus.externalId()).getOrElse((_) => const None());
user.match(() => showSignIn(), (final String id) => showHome(id));
```

---

## API reference

All functions are static on `SignalPlus`. An operation called before `init` returns `Left(SignalPlus.notInitialized)`. The exceptions are the event listeners, `onBackgroundMessage`, `installationId()` and `externalId()`, which work at any time.

Every call that is about this device runs one at a time, so an automatic re-registration never interleaves with a sign-in or a settings change.

### Setup

#### `init(SignalPlusConfig config)` → `Future<Either<ServiceFailure, Unit>>`

Starts everything in one call. Call it once, before `runApp`.

1. Initializes Firebase, from the native files or `config.firebaseOptions`.
2. Creates the default Android channel `signalplus_default`, named in the app's language, and takes the app's own name as the fallback title.
3. Starts local notifications and the FCM listeners for foreground, tap, launch and token refresh.
4. Registers the internal background handler.
5. Fetches the FCM token, and asks for permission when `requestPermissionOnStartup` is `true`.
6. Registers the device with the SDK API when `registerOnStart` is `true` (in the background; `init` does not wait for it).

Calling it again after success returns `Right(unit)` immediately. Concurrent calls share one start. After a failure, it can be called again.

#### `dispose()` → `Future<void>`

Cancels the listeners, stops the push side and closes the HTTP client. The `onMessage` and `onNotificationTap` streams stay open for the app's lifetime. Mostly useful in tests.

#### `isInitialized` → `bool`

`true` after a successful `init`.

---

### Events

Each listener returns a `StreamSubscription`; call `cancel()` on it to stop listening. You can register several listeners.

#### `onMessage(void Function(RemoteMessage message) handler)` → `StreamSubscription<RemoteMessage>`

Called for every message that arrives while the app is **in the foreground**. On Android the package also shows it as a local notification; on iOS the system banner shows it. Turn display off with `showForegroundNotification: false`.

```dart
final StreamSubscription<RemoteMessage> subscription = SignalPlus.onMessage((final RemoteMessage message) {
  if (message.data['Category'] == 'Orders') refreshOrders();
});
```

#### `onNotificationTap(void Function(NotificationPayload payload) handler)` → `StreamSubscription<NotificationPayload>`

Called when the user taps a notification while the app is running, in the foreground or background. It is also called **once** for the tap that launched a closed app, after the first frame. If a `NotifyId` is present, `Opened` is reported to the service automatically.

```dart
SignalPlus.onNotificationTap((final NotificationPayload payload) {
  final Object? route = payload.data['route'];
  if (route is String) navigatorKey.currentState?.pushNamed(route);
});
```

#### `onBackgroundMessage(Future<void> Function(RemoteMessage message) handler)` → `Future<Either<ServiceFailure, Unit>>`

Runs `handler` for messages received while the app is **in the background or closed**. Data-only messages are shown as local notifications first, using `data['title']` and `data['body']`. The handler runs in a separate isolate, so:

- it must be a **top-level or static** function, marked `@pragma('vm:entry-point')`;
- it cannot use state from `main()`;
- a closure returns `Left` (`BACKGROUND_HANDLER_ERROR`).

```dart
@pragma('vm:entry-point')
Future<void> onBackground(final RemoteMessage message) async {
  // e.g. store the message for later
}

await SignalPlus.onBackgroundMessage(onBackground);
```

---

### Push

#### `requestPermission()` → `Future<Either<ServiceFailure, PushPermission>>`

Shows the system permission dialog; concurrent calls share one dialog. A change in permission registers the device again.

#### `permission()` → `Future<Either<ServiceFailure, PushPermission>>`

The current permission, without asking.

```dart
final bool canNotify = (await SignalPlus.permission()).exists((final PushPermission p) => p.canDeliver);
```

#### `token()` → `Future<Either<ServiceFailure, String>>`

The current FCM token. On iOS it waits briefly for the APNs token. If APNs never arrives, the failure details are `APNS_TOKEN_NOT_READY`; test on a real device.

#### `deleteToken()` → `Future<Either<ServiceFailure, Unit>>`

Deletes the FCM token on the device. FCM issues a new one later.

#### `clearNotifications()` → `Future<Either<ServiceFailure, Unit>>`

Removes every notification shown in the notification center, including those delivered by FCM. Scheduled ones are kept.

---

### Device, language and sign-in

The device registers by itself: after `init`, and again on every FCM token or permission change. There is no call to register it yourself.

#### `setLocale(ServiceLocale locale)` → `Future<Either<ServiceFailure, SdkInstallationEntity>>`

Call it when the user switches the app's language. One call is enough: it registers the device again in the new language, and the service gives the same language and the device's time zone to the user signed in on it. Every later call asks for the new language too (category names, preferences), and the Android channels are renamed: the default one, and the category channels if `categories()` created them.

```dart
await SignalPlus.setLocale(ServiceLocale.en);
```

#### `login(String externalId)` → `Future<Either<ServiceFailure, SdkInstallationEntity>>`

Signs this device in as `externalId`, the user's id in your system, after they sign in to the app. The user is created if new and takes the device's language and time zone.

```dart
await SignalPlus.login(session.userId);
```

#### `logout()` → `Future<Either<ServiceFailure, SdkInstallationEntity>>`

Signs this device out when the user signs out of the app. It is the only call SignalPlus needs on sign-out: it also forgets the external id the package saved. The device stays registered without a user, so whoever uses the phone next does not get the previous user's notifications. Your app's own session (its sign-in tokens) is yours to clear; SignalPlus neither needs nor touches it.

#### `installationId()` → `Future<Either<ServiceFailure, String>>`

The stored installation id, created on first use. Works before `init`. If your backend also registers devices (`PUT /v1/installations/{installationId}`), send it this id and register with it, so both name the device the same way; otherwise the token moves between two records. Your backend also uses it to read, detach or delete this device.

#### `externalId()` → `Future<Either<ServiceFailure, Option<String>>>`

The user signed in on this device, as last seen by the package; `None()` when nobody is. Works before `init`.

---

### The signed-in user

Every function from here on acts on the user signed in on this device. While nobody is, the service answers `NotSignedIn` (403).

### Notification settings

#### `preferences()` → `Future<Either<ServiceFailure, PreferencesEntity>>`

Every category of the application, its name in the user's language, enabled or not, and the quiet hours (`None()` when there are none).

#### `updatePreferences(List<CategoryChoiceEntity> choices)` → `Future<Either<ServiceFailure, UpdatedPreferencesEntity>>`

Turns categories on or off. Categories not listed keep their setting. A locked category turned off, or an unknown one, comes back in `rejected` (`CategoryLocked`, `CategoryUnknown`) while the rest apply.

```dart
await SignalPlus.updatePreferences(<CategoryChoiceEntity>[const CategoryChoiceEntity(key: 'Promotions', enabled: false)]);
```

#### `setQuietHours(QuietHoursEntity quietHours)` → `Future<Either<ServiceFailure, PreferencesEntity>>`

Holds notifications during a window in the user's time zone. `start` equal to `end` is refused (400).

```dart
await SignalPlus.setQuietHours(const QuietHoursEntity(start: '23:00', end: '07:00', days: <WeekDay>[WeekDay.thu, WeekDay.fri]));
```

#### `clearQuietHours()` → `Future<Either<ServiceFailure, PreferencesEntity>>`

Removes the quiet hours and answers the settings without them.

---

### Topics

Topics are created only on the environment's **Topics** screen in the dashboard. Neither the app nor your backend can create one.

#### `topics()` → `Future<Either<ServiceFailure, List<String>>>`

Every topic defined in the dashboard, by name, to build a "choose what to follow" screen. It needs no signed-in user and no device.

```dart
final List<String> available = (await SignalPlus.topics()).getOrElse((_) => <String>[]);
final List<String> following = (await SignalPlus.recipientTopics()).getOrElse((_) => <String>[]);
```

The next three answer the topics the user now follows.

#### `recipientTopics()` → `Future<Either<ServiceFailure, List<String>>>`

#### `subscribe(String topic)` → `Future<Either<ServiceFailure, List<String>>>`

Only for a topic defined in the dashboard; any other answers `TopicNotFound` (404). A topic the user already follows is always accepted.

#### `unsubscribe(String topic)` → `Future<Either<ServiceFailure, List<String>>>`

Always works.

---

### Categories

#### `categories({bool createChannels = true})` → `Future<Either<ServiceFailure, List<CategoryEntity>>>`

The application's categories, names in the app's language. It needs no signed-in user and no device, so call it at start. With `createChannels`, one Android channel is created per category on its `AndroidChannelId` (the key when none is set), with an importance taken from its lane.

---

### Opens

#### `reportOpened(NotificationPayload payload)` → `Future<Either<ServiceFailure, bool>>`

Reports that a notification was opened on this device. It returns `Right(false)` when the payload has no `NotifyId`, or when the notification was not sent to this device. Taps are already reported automatically, so use this only for opens you handle yourself, such as an in-app list. It needs no signed-in user.

---

## Your backend's part

The app needs nothing from your backend to use SignalPlus: no key, no proxy, no extra field in your sign-in response. Your backend keeps only what is not the user's to do, through the Service API with the environment's API key: sending notifications, deleting a user's account, signing them out of every device, exporting their data, and reading or removing devices. It can also register devices with the installation id the app sends it (`installationId()`) and manage tags. It does not create topics: they are created in the dashboard.

---

## SignalPlusConfig

| Option | Type | Default | Description |
|---|---|---|---|
| `appId` | `String` | **Required** | The environment's App ID (`sdk_…`) from Environment → App SDK. |
| `locale` | `ServiceLocale` | **Required** | The app's language: `ServiceLocale.ar` or `ServiceLocale.en`. Used for `Accept-Language` and the device registration. |
| `push` | `PushConfig` | `PushConfig()` | How notifications are shown; see below. |
| `registerOnStart` | `bool` | `true` | Register the device right after `init`. |
| `baseUrl` | `String` | SignalPlus API | The SignalPlus host. A path prefix is kept, e.g. `https://edge.example.com/signalplus` → `…/signalplus/sdk/v1/…`. |
| `timeout` | `Duration` | 20 s | Timeout per request. |
| `firebaseOptions` | `Option<FirebaseOptions>` | `None()` | Only when the app has no native Firebase files. |

### PushConfig

Optional: `push` defaults to `const PushConfig()`. The app's name and the default channel are not options; the package sets them itself:

| What | Value |
|---|---|
| Fallback title, when a message has none | The app's own name, as installed (`package_info_plus`). |
| Default Android channel id | `signalplus_default` (`PushConfig.defaultChannelId`). Use it in `AndroidManifest.xml`. |
| Its name and description in Android settings | Built in: "الإشعارات العامة" in Arabic, "General notifications" in English. They follow `setLocale`. |

| Option | Type | Default | Description |
|---|---|---|---|
| `notificationIcon` | `String` | `'@mipmap/ic_launcher'` | Android small icon; use a white, transparent drawable. |
| `requestPermissionOnStartup` | `bool` | `true` | Ask for permission right after `init`. Set it to `false` to ask later with `requestPermission()`. |
| `showForegroundNotification` | `bool` | `true` | Show messages while the app is open. |
| `clearNotificationsOnLaunch` | `bool` | `false` | Remove displayed notifications on start. |
| `groupNotifications` | `bool` | `false` | Group foreground notifications under one summary on Android. |
| `groupSummary` | `String Function(int)` | the count | Text of the Android group summary. |
| `showNotificationImages` | `bool` | `true` | Download and attach notification images. |
| `enableLogs` | `bool` | `true` | Print internal logs in debug. |
| `logger` | `Option<LogSink>` | `None()` | Send internal logs to your own logger: `Some((tag, message) => …)`. |

---

## Types

### NotificationPayload

What a tap delivers.

| Field | Type | Description |
|---|---|---|
| `title` | `String` | The title, or `appName` when there is none. |
| `body` | `String` | The body. |
| `data` | `Map<String, dynamic>` | Every `data` key the backend sent. |
| `notifyId` | `Option<String>` | The service's notification id, from `data['NotifyId']`. |
| `category` | `Option<String>` | The category key, from `data['Category']`. |
| `rawPayload` | `Option<String>` | The original text of a local notification payload that is not JSON. |

### SdkInstallationEntity

What `setLocale`, `login` and `logout` return.

| Field | Type |
|---|---|
| `installationId` | `String` |
| `externalId` | `Option<String>`: the signed-in user, `None()` while signed out |
| `tokenStatus` | `TokenStatus` |
| `pushPermission` | `PushPermission` |

### Preferences

| Type | Fields |
|---|---|
| `PreferencesEntity` | `categories: List<CategoryPreferenceEntity>`, `quietHours: Option<QuietHoursEntity>` |
| `CategoryPreferenceEntity` | `key`, `name`, `enabled`, `locked` |
| `QuietHoursEntity` | `start`, `end` (`HH:mm`), `days: List<WeekDay>` |
| `CategoryChoiceEntity` | `key`, `enabled`: input to `updatePreferences` |
| `UpdatedPreferencesEntity` | `categories`, `quietHours`, `rejected: List<RejectedChoiceEntity>` (`key`, `error`) |

### CategoryEntity

| Field | Type |
|---|---|
| `key` | `String` |
| `name` | `String`: in the request language, else the application's default |
| `description` | `Option<String>` |
| `androidChannelId` | `Option<String>`; `channelId` gives it, or the key when none is set |
| `lane` | `Lane` (`critical`, `transactional`, `bulk`) |
| `locked`, `defaultEnabled` | `bool` |

### Enums

Each enum has a `wire` value, the text the service uses. A value the package does not know becomes `unknown` instead of failing.

| Enum | Values |
|---|---|
| `ServiceLocale` | `ar`, `en` |
| `PushPermission` | `granted`, `denied`, `provisional`, `notDetermined` (`canDeliver` is true for granted and provisional) |
| `DevicePlatform` | `android`, `ios`, `unknown` |
| `TokenStatus` | `valid`, `invalid`, `expired` |
| `WeekDay` | `sun` … `sat` |
| `Lane` | `critical`, `transactional`, `bulk` |
| `DeliveryEventType` | `created` … `opened`, `dismissed` |

---

## Errors

A failure is `Left(ServiceFailure)`:

| Field | Description |
|---|---|
| `type` | `FailureType`: `connection`, `timeout`, `unauthenticated` (401), `server`, `decoding`, `platform`, `unknown`. `type.isNetwork` is true for connection and timeout. |
| `operation` | Which call failed, e.g. `GET_PREFERENCES_ERROR`. |
| `statusCode` | The HTTP status, or `-1`. |
| `errorCode` | `Option<String>`: the stable code from the service. Branch on this, never on the text. |
| `serverMessage` | `Option<String>`: the service's message in the request language. |
| `message` | `serverMessage`, otherwise `errorCode`, otherwise the type code. |
| `fieldErrors` | `List<FieldError>` (`property`, `code`, `message`) for `ValidationFailed`. |
| `correlationId` | `Option<String>`: give it to the backend team for `InternalError`. |
| `details` | Technical details for logs. |

`failure.hasCode(code)` checks `errorCode` and the field error codes, and `failure.fieldError('Set.plan')` finds one field error.

| `ServiceErrorCodes` | When |
|---|---|
| `notSignedIn` | A user function while nobody is signed in on this device (403). Call `login` first. |
| `topicNotFound` | A subscribe to a topic the dashboard never created (404). |
| `appIdInvalid` | The App ID is missing or unknown, or its environment is being deleted (401). |
| `installationNotFound` | The service does not know this device. The package registers it again and retries by itself. |
| `tenantSuspended` | The tenant is suspended (403). |
| `validationFailed` | A field is invalid (400); see `fieldErrors`. |
| `categoryLocked` / `categoryUnknown` | In `UpdatedPreferencesEntity.rejected`. |
| `rateLimited` | Too many calls from this network (429). |
| `internalError` | Server error (500); see `correlationId`. |

```dart
(await SignalPlus.preferences()).match(
  (final ServiceFailure failure) {
    if (failure.hasCode(ServiceErrorCodes.notSignedIn)) return openSignIn();
    if (failure.type.isNetwork) return showOffline();
    showError(failure.message);
  },
  showSettings,
);
```

---

## Message format

What a device receives from the service:

```json
{
  "notification": { "title": "Order shipped", "body": "Arrives in about 35 minutes", "image": "https://cdn.example.com/order.jpg" },
  "data": { "NotifyId": "ntf_01J9Z3…", "Category": "Orders", "OrderId": "1042", "route": "/orders" }
}
```

- `NotifyId` and `Category` are reserved: the service adds them, and the package uses them to report opens and pick channels.
- Every other `data` key is your backend's choice and reaches `payload.data` unchanged. FCM requires every value to be a string.
- **Data-only messages** have no `notification` block. The package shows them using `data['title']`, `data['body']` and `data['image']`.
- **iOS:** data-only messages are throttled, and they are not delivered after the user force-quits the app. For anything the user must see, use a `notification` block.

### Images

| Message | Android | iOS |
|---|---|---|
| `notification.image`, any state | ✅ | ✅ after `setup_ios` |
| data-only with `data.image` | ✅ | ✅ (with the data-only limits above) |

Use JPEG, PNG or GIF over **https**, under 1 MB (FCM's limit for `notification.image`), with the file extension at the end of the URL. The package itself stops downloading at 5 MB.

On iOS, images need a Notification Service Extension. Add it once from your app's root:

```bash
dart run signalplus:setup_ios
```

It creates `ios/NotificationService/` and adds the target to `Runner.xcodeproj` with Runner's team and signing; running it again does nothing. It needs the `xcodeproj` gem, which comes with CocoaPods. With **manual** signing, register an App ID `<bundle id>.NotificationService` and create a provisioning profile for it.

---

## Platform setup

### Android

1. Add `google-services.json` (`flutterfire configure` does this).
2. Declare the Android 13+ permission in `AndroidManifest.xml`:
   ```xml
   <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
   ```
3. Set the icon and default channel for notifications shown by the system in the background. The channel is always `signalplus_default`:
   ```xml
   <meta-data
       android:name="com.google.firebase.messaging.default_notification_icon"
       android:resource="@drawable/ic_notification" />
   <meta-data
       android:name="com.google.firebase.messaging.default_notification_channel_id"
       android:value="signalplus_default" />
   ```
4. Use `compileSdk` 35+ and AGP 8.11.1+, and turn on core library desugaring in `android/app/build.gradle.kts`:
   ```kotlin
   android {
       compileOptions { isCoreLibraryDesugaringEnabled = true }
   }
   dependencies {
       coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
   }
   ```

### iOS

1. Add `GoogleService-Info.plist` (`flutterfire configure`).
2. Upload an **APNs authentication key** (`.p8`) in Firebase Console → Project settings → Cloud Messaging.
3. In Xcode, target **Runner** → Signing & Capabilities: add **Push Notifications**, and **Background Modes** with **Remote notifications**.
4. Run `dart run signalplus:setup_ios` for images.
5. Test on a real device; the simulator does not receive remote push reliably.

---

## Typical flows

**App start**

```dart
await SignalPlus.init(config); // registers the device by itself
SignalPlus.onNotificationTap(openFromNotification);
await SignalPlus.onBackgroundMessage(onBackground);
await SignalPlus.categories(); // the category channels
```

**Sign-in**

```dart
await SignalPlus.login(user.id);
```

**Notification settings screen**

```dart
final Either<ServiceFailure, PreferencesEntity> current = await SignalPlus.preferences();
await SignalPlus.updatePreferences(<CategoryChoiceEntity>[CategoryChoiceEntity(key: key, enabled: value)]);
await SignalPlus.setQuietHours(const QuietHoursEntity(start: '23:00', end: '07:00', days: WeekDay.values));
final List<String> available = (await SignalPlus.topics()).getOrElse((_) => <String>[]);
await SignalPlus.subscribe('news');
```

**Language switch**

```dart
await SignalPlus.setLocale(ServiceLocale.en);
```

**Sign-out**

```dart
await SignalPlus.logout();
```

---

## Limitations

- **Background handler:** it must be a top-level or static function marked `@pragma('vm:entry-point')`.
- **iOS data-only messages** are throttled and not delivered after a force-quit.
- **Sending** notifications is not part of this package; it is done by your backend.
- **What the app may not do** (account deletion, sign-out everywhere, data export) goes through your backend and the Service API. Topics and tags are managed in the dashboard.
