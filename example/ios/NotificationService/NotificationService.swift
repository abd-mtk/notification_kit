import UserNotifications

final class NotificationService: UNNotificationServiceExtension {
  private let lock = NSLock()
  private var contentHandler: ((UNNotificationContent) -> Void)?
  private var content: UNMutableNotificationContent?

  override func didReceive(
    _ request: UNNotificationRequest,
    withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void
  ) {
    self.contentHandler = contentHandler
    content = request.content.mutableCopy() as? UNMutableNotificationContent

    guard let url = imageURL(in: request.content.userInfo) else { return finish() }

    URLSession.shared.downloadTask(with: url) { location, response, _ in
      guard let location, (response as? HTTPURLResponse)?.statusCode == 200 else { return self.finish() }
      self.finish(with: self.attachment(from: location, response: response))
    }.resume()
  }

  override func serviceExtensionTimeWillExpire() {
    finish()
  }

  private func finish(with attachment: UNNotificationAttachment? = nil) {
    lock.lock()
    defer { lock.unlock() }
    guard let contentHandler, let content else { return }
    if let attachment { content.attachments = [attachment] }
    self.contentHandler = nil
    contentHandler(content)
  }

  private func imageURL(in userInfo: [AnyHashable: Any]) -> URL? {
    let fcmImage = (userInfo["fcm_options"] as? [String: Any])?["image"] as? String
    guard let value = fcmImage ?? (userInfo["image"] as? String),
          let url = URL(string: value),
          url.scheme == "https" || url.scheme == "http" else { return nil }
    return url
  }

  private func attachment(from location: URL, response: URLResponse?) -> UNNotificationAttachment? {
    let fileExtension = response?.suggestedFilename.map { ($0 as NSString).pathExtension } ?? ""
    let file = FileManager.default.temporaryDirectory
      .appendingPathComponent(UUID().uuidString)
      .appendingPathExtension(fileExtension.isEmpty ? "jpg" : fileExtension)
    do {
      try FileManager.default.moveItem(at: location, to: file)
      return try UNNotificationAttachment(identifier: "image", url: file)
    } catch {
      return nil
    }
  }
}
