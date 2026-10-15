## 0.1.0

The first release of `signalplus`: one static facade, `SignalPlus`, that receives push notifications and lets the signed-in user manage their own notification settings, through the SignalPlus SDK API (`/sdk/v1`) with the environment's public App ID. No API key in the app, no proxy in your backend.

* `SignalPlus.init(SignalPlusConfig(appId:, locale:))` sets up Firebase, the Android channels and the client, and registers the device by itself.
* The device registers again on every FCM token or permission change, under one installation id per install; a device the service no longer knows is registered again and the call retried once.
* `login(externalId)` and `logout()` link and unlink the signed-in user.
* `setLocale(ServiceLocale)` changes the language of the device and the signed-in user in one call; the time zone follows the device.
* Notification settings: `preferences`, `updatePreferences`, `setQuietHours`, `clearQuietHours`.
* Topics created in the dashboard: `topics`, `recipientTopics`, `subscribe`, `unsubscribe`.
* `categories()` creates one Android channel per category, before anyone signs in.
* Taps report `Opened` by themselves; `reportOpened` covers opens you handle yourself.
* Events: `onMessage`, `onNotificationTap` (including the launch tap) and `onBackgroundMessage`.
* The app name and the default channel (`signalplus_default`) are set by the package, named in the app's language.
* Every call returns `Either<ServiceFailure, T>` and never throws.
