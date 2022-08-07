//
//  MockMessage.swift
//  FavoriteLinks
//
//  Created by 田中裕貴 on 2020/11/01.
//  Copyright © 2020 田中裕貴. All rights reserved.
//

import CoreLocation
import Foundation
import MessageKit

private struct MockLocationItem: LocationItem {

  var location: CLLocation
  var size: CGSize

  init(location: CLLocation) {
    self.location = location
    self.size = CGSize(width: 240, height: 240)
  }
}

private struct MockMediaItem: MediaItem {

  var url: URL?
  var image: UIImage?
  var placeholderImage: UIImage
  var size: CGSize

  init(image: UIImage) {
    self.image = image
    self.size = CGSize(width: 240, height: 240)
    self.placeholderImage = UIImage()
  }
}

internal struct MockMessage: MessageType {
  var sender: SenderType
  var messageId: String
  var sentDate: Date
  var kind: MessageKind

  private init(kind: MessageKind, sender: SenderType, messageId: String, date: Date) {
    self.kind = kind
    self.sender = sender
    self.messageId = messageId
    self.sentDate = date
  }

  init(text: String, sender: SenderType, messageId: String, date: Date) {
    self.init(kind: .text(text), sender: sender, messageId: messageId, date: date)
  }

  init(attributedText: NSAttributedString, sender: SenderType, messageId: String, date: Date) {
    self.init(
      kind: .attributedText(attributedText), sender: sender, messageId: messageId, date: date)
  }

  init(image: UIImage, sender: SenderType, messageId: String, date: Date) {
    let mediaItem = MockMediaItem(image: image)
    self.init(kind: .photo(mediaItem), sender: sender, messageId: messageId, date: date)
  }

  init(thumbnail: UIImage, sender: SenderType, messageId: String, date: Date) {
    let mediaItem = MockMediaItem(image: thumbnail)
    self.init(kind: .video(mediaItem), sender: sender, messageId: messageId, date: date)
  }

  init(location: CLLocation, sender: SenderType, messageId: String, date: Date) {
    let locationItem = MockLocationItem(location: location)
    self.init(kind: .location(locationItem), sender: sender, messageId: messageId, date: date)
  }

  init(emoji: String, sender: SenderType, messageId: String, date: Date) {
    self.init(kind: .emoji(emoji), sender: sender, messageId: messageId, date: date)
  }
}
