//
//  ChatViewController.swift
//  FavoriteLinks
//
//  Created by 田中裕貴 on 2020/10/23.
//  Copyright © 2020 田中裕貴. All rights reserved.
//

import Firebase
import FirebaseStorage
import InputBarAccessoryView
import MessageKit
import UIKit

class ChatViewController: MessagesViewController {

  let db = Firestore.firestore()
  let uid = Auth.auth().currentUser!.uid as String
  var userName: String = ""
  var roomName: String!
  var roomDocId: String!
  var messageList: [MockMessage] = []
  var uidToName: [String: String] = [:]
  var uidToImage: [String: UIImage] = [:]

  lazy var formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
  }()

  override func viewDidLoad() {
    super.viewDidLoad()

    messagesCollectionView.messagesDataSource = self
    messagesCollectionView.messagesLayoutDelegate = self
    messagesCollectionView.messagesDisplayDelegate = self
    messagesCollectionView.messageCellDelegate = self

    messageInputBar.delegate = self
    messageInputBar.sendButton.tintColor = UIColor.lightGray

    scrollsToBottomOnKeyboardBeginsEditing = true
    maintainPositionOnKeyboardFrameChanged = true

    addUserId(uid: uid)
  }

  func addUserId(uid: String) {
    var ref: DocumentReference? = nil
    ref = self.db.collection("rooms").document(roomDocId)
    ref?.updateData([
      "userIds": FieldValue.arrayUnion([uid])
    ]) { err in
      if let err = err {
        print("Error adding document: \(err)")
      } else {
        print("Document added with ID: \(ref!.documentID)")
        self.getUserName(uid: uid)
      }
    }
  }

  func getUserName(uid: String) {
    let docRef = db.collection("users").document(uid)
    docRef.getDocument { (document, error) in
      if let document = document, document.exists {
        let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
        print("Document data: \(dataDescription)")
        self.userName = document.get("userName") as! String
        self.getUserIds()
      } else {
        print("Document does not exist")
      }
    }
  }

  func getUserIds() {
    let docRef = db.collection("rooms").document(roomDocId)
    docRef.addSnapshotListener {
      querySnapshot, error in
      guard let data = querySnapshot?.data() else {
        print("Error fetching data: \(error!)")
        return
      }
      let dataDescription = data.map(String.init(describing:))
      print("Document data: \(dataDescription)")
      let userIds = querySnapshot?.data()!["userIds"] as! [String]
      self.getUserNames(userIds: userIds)
    }
  }

  func getUserNames(userIds: [String]) {
    let docRef = db.collection("users").whereField("uid", in: userIds)
    docRef.getDocuments { (querySnapshot, err) in
      if let err = err {
        print("Error getting documents: \(err)")
      } else {
        for document in querySnapshot!.documents {
          print("\(document.documentID) => \(document.data())")
          let userName = document.data()["userName"] as! String
          let uid = document.data()["uid"] as! String
          let profileImageUrl = document.data()["profileImageUrl"] as? String
          self.uidToName[uid] = userName
          if let profileImageUrl = profileImageUrl {
            do {
              let data = try Data(contentsOf: URL(string: profileImageUrl)!)
              self.uidToImage[uid] = UIImage(data: data)
            } catch _ {
              self.uidToImage[uid] = UIImage()
            }
          } else {
            self.uidToImage[uid] = UIImage()
          }
        }
        self.getMessagesData()
      }
    }
  }

  func getMessagesData() {
    db.collection("rooms").document(roomDocId).collection("messages").order(by: "date")
      .addSnapshotListener {
        querySnapshot, error in
        guard let documents = querySnapshot?.documents else {
          print("Error fetching documents: \(error!)")
          return
        }
        self.messageList.removeAll()
        for document in documents {
          document.data()
          print(document.data())
          let userId = document.get("userId") as! String
          let message = document.get("message") as! String
          let timestamp = document.get("date") as! Timestamp
          let userName = self.uidToName[userId]

          self.insertNewMessage(
            text: message, sender: Sender(senderId: userId, displayName: userName ?? "無名"),
            date: timestamp.dateValue())
        }
        self.messagesCollectionView.reloadData()
        self.messagesCollectionView.scrollToBottom()
      }
  }

  func insertNewMessage(text: String, sender: SenderType, date: Date) {
    let attributedText = NSAttributedString(
      string: text,
      attributes: [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: UIColor.white])
    let message = MockMessage(
      attributedText: attributedText, sender: sender, messageId: UUID().uuidString,
      date: date)
    messageList.append(message)
  }

  func uploadMessage(text: String) {
    let message: [String: Any] = [
      "message": text,
      "date": Date(),
      "userId": uid,
    ]
    let ref = db.collection("rooms").document(roomDocId).collection("messages")
    ref.addDocument(data: message)
  }
}

extension ChatViewController: MessagesDataSource {
  func currentSender() -> SenderType {
    return Sender(senderId: uid, displayName: userName)
  }

  func otherSender() -> SenderType {
    return Sender(senderId: "456", displayName: "知らない人")
  }

  func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView)
    -> MessageType
  {
    return messageList[indexPath.section]
  }

  func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
    return messageList.count
  }

  func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath)
    -> NSAttributedString?
  {
    if indexPath.section % 3 == 0 {
      return NSAttributedString(
        string: MessageKitDateFormatter.shared.string(from: message.sentDate),
        attributes: [
          NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10),
          NSAttributedString.Key.foregroundColor: UIColor.darkGray,
        ]
      )
    }
    return nil
  }

  func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath)
    -> NSAttributedString?
  {
    let name = message.sender.displayName
    return NSAttributedString(
      string: name,
      attributes: [
        NSAttributedString.Key.font:
          UIFont.preferredFont(forTextStyle: .caption1)
      ])
  }

  func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath)
    -> NSAttributedString?
  {
    let dateString = formatter.string(from: message.sentDate)
    return NSAttributedString(
      string: dateString,
      attributes: [
        NSAttributedString.Key.font:
          UIFont.preferredFont(forTextStyle: .caption2)
      ])
  }
}

extension ChatViewController: MessagesLayoutDelegate {
  func cellTopLabelHeight(
    for message: MessageType, at indexPath: IndexPath,
    in messagesCollectionView: MessagesCollectionView
  ) -> CGFloat {
    if indexPath.section % 3 == 0 { return 10 }
    return 0
  }

  func messageTopLabelHeight(
    for message: MessageType, at indexPath: IndexPath,
    in messagesCollectionView: MessagesCollectionView
  ) -> CGFloat {
    return 16
  }

  func messageBottomLabelHeight(
    for message: MessageType, at indexPath: IndexPath,
    in messagesCollectionView: MessagesCollectionView
  ) -> CGFloat {
    return 16
  }
}

extension ChatViewController: MessagesDisplayDelegate {
  func textColor(
    for message: MessageType, at indexPath: IndexPath,
    in messagesCollectionView: MessagesCollectionView
  ) -> UIColor {
    return isFromCurrentSender(message: message) ? .black : .darkText
  }

  func backgroundColor(
    for message: MessageType, at indexPath: IndexPath,
    in messagesCollectionView: MessagesCollectionView
  ) -> UIColor {
    return isFromCurrentSender(message: message)
      ? UIColor(red: 69 / 255, green: 193 / 255, blue: 89 / 255, alpha: 1)
      : UIColor(red: 230 / 255, green: 230 / 255, blue: 230 / 255, alpha: 1)
  }
  func messageStyle(
    for message: MessageType, at indexPath: IndexPath,
    in messagesCollectionView: MessagesCollectionView
  ) -> MessageStyle {
    let corner: MessageStyle.TailCorner =
      isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
    return .bubbleTail(corner, .curved)
  }
  func configureAvatarView(
    _ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath,
    in messagesCollectionView: MessagesCollectionView
  ) {
    let profileImageUid = message.sender.senderId
    let avatar = Avatar(image: uidToImage[profileImageUid], initials: "名前")
    avatarView.set(avatar: avatar)
  }
}

extension ChatViewController: MessageCellDelegate {
  func didTapMessage(in cell: MessageCollectionViewCell) {
    print("Message tapped")
  }

}

extension ChatViewController: InputBarAccessoryViewDelegate {
  func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
    for component in inputBar.inputTextView.components {
      if let image = component as? UIImage {
        let imageMessage = MockMessage(
          image: image, sender: currentSender(), messageId: UUID().uuidString, date: Date())
        messageList.append(imageMessage)
        //messagesCollectionView.insertSections([messageList.count - 1])
      } else if let text = component as? String {

        uploadMessage(text: text)

        insertNewMessage(text: text, sender: currentSender(), date: Date())
        messagesCollectionView.insertSections([messageList.count - 1])
      }
    }
    inputBar.inputTextView.text = String()
    messagesCollectionView.scrollToBottom()
  }

}
