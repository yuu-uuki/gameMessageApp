//
//  EditMypage.swift
//  FavoriteLinks
//
//  Created by 田中裕貴 on 2021/01/12.
//  Copyright © 2021 田中裕貴. All rights reserved.
//

import Firebase
import UIKit

class EditMypageViewController: UIViewController {
  @IBOutlet weak var profileImageButton: UIButton!
  @IBOutlet weak var userNameTextField: UITextField!
  @IBOutlet weak var changeToButton: UIButton!

  let db = Firestore.firestore()
  let storage = Storage.storage()

  override func viewDidLoad() {
    super.viewDidLoad()
    changeToButton.layer.cornerRadius = 10
    profileImageButton.layer.cornerRadius = 90
    profileImageButton.layer.borderWidth = 0.5
    profileImageButton.layer.borderColor = UIColor.black.cgColor
  }
  @IBAction func backButton(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }

  @IBAction func tappedPrpfileImageButton(_ sender: Any) {
    tappedProfileImageButton()
  }
  @IBAction func tappedChangeButton(_ sender: Any) {
    firestoragePutData()
  }
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    self.view.endEditing(true)
  }

  func tappedProfileImageButton() {
    let imagePickerController = UIImagePickerController()
    imagePickerController.delegate = self
    imagePickerController.allowsEditing = true
    self.present(imagePickerController, animated: true, completion: nil)
  }

  func firestoragePutData() {
    let image = profileImageButton.imageView?.image ?? nil
    if let profileImage = image {
      guard let uploadImage = profileImage.jpegData(compressionQuality: 0.3) else { return }
      let uid = Auth.auth().currentUser!.uid as String
      let storageRef = storage.reference().child("profile_image").child(uid)
      storageRef.putData(uploadImage, metadata: nil) { (metadata, err) in
        if let err = err {
          print("Firestorageへの情報の保存に失敗しました\(err)")
          return
        }
        print("Firestorageへの情報の保存に成功しました")
        storageRef.downloadURL { (url, err) in
          if let err = err {
            print("Firestorageからのダウンロードに失敗しました\(err)")
            return
          }
          let urlString = url!.absoluteString
          print("urlString: ", urlString)
          self.createToFirestore(profileImageUrl: urlString)
        }
      }
    } else {
      self.createToFirestore(profileImageUrl: "")
    }
  }

  func createToFirestore(profileImageUrl: String) {
    let uid = Auth.auth().currentUser!.uid as String
    let userName = self.userNameTextField.text! as String
    var ref: DocumentReference? = nil
    ref = self.db.collection("users").document(uid)
    if userName.isEmpty {
      print("画像のみ")
      ref?.updateData([
        "profileImageUrl": profileImageUrl
      ]) { err in
        if let err = err { print("Error adding document: \(err)") }
        else { print("Document added with ID: \(ref!.documentID)") }
      }
    } else if profileImageUrl.isEmpty {
      print("ユーザーネームのみ")
      ref?.updateData([
        "userName": userName
      ]) { err in
        if let err = err { print("Error adding document: \(err)") }
        else { print("Document added with ID: \(ref!.documentID)") }
      }
      return
    } else {
      print("両方")
      ref?.updateData([
        "userName": userName,
        "profileImageUrl": profileImageUrl,
      ]) { err in
        if let err = err { print("Error adding document: \(err)") }
        else { print("Document added with ID: \(ref!.documentID)") }
      }
    }
    self.dismiss(animated: true, completion: nil)
  }
}
extension EditMypageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
  func imagePickerController(
    _ picker: UIImagePickerController,
    didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
  ) {
    if let editImage = info[.editedImage] as? UIImage {
      profileImageButton.setImage(editImage.withRenderingMode(.alwaysOriginal), for: .normal)
    } else if let originalImage = info[.editedImage] as? UIImage {
      profileImageButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
    }
    profileImageButton.setTitle("", for: .normal)
    profileImageButton.imageView?.contentMode = .scaleAspectFill
    profileImageButton.contentHorizontalAlignment = .fill
    profileImageButton.contentVerticalAlignment = .fill
    profileImageButton.clipsToBounds = true
    dismiss(animated: true, completion: nil)
  }
}
