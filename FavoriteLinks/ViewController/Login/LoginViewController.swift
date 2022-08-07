//
//  ViewController.swift
//  FavoriteLinks
//
//  Created by 田中裕貴 on 2020/08/09.
//  Copyright © 2020 田中裕貴. All rights reserved.
//

import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate, FSUserLoginDelegate {
    func createToFirestore(profileImageUrl: String)  {
        createUserToFirestore(profileImageUrl: profileImageUrl)
    }
    func onLoginSucceeded() {
        firestoragePutData()
        let storyboard = UIStoryboard(name: "Tab", bundle: nil)
        let view = storyboard.instantiateInitialViewController()
        view?.modalPresentationStyle = .fullScreen
        self.present(view!, animated: true, completion: nil)
    }
    
    func onLoginFailed(message: String){
        self.error(title: "エラー", message: message)
    }
    
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var pwTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var profileImageButton: UIButton!

  private let db = Firestore.firestore()
  private let storage = Storage.storage()

  override func viewDidLoad() {
    super.viewDidLoad()
    FSUser.fsUserLoginDelegate = self
    loginButton.layer.cornerRadius = 10
    NotificationCenter.default.addObserver(
      self, selector: #selector(showKeyboard), name: UIResponder.keyboardWillShowNotification,
      object: nil)
    NotificationCenter.default.addObserver(
      self, selector: #selector(hideKeyboard), name: UIResponder.keyboardWillHideNotification,
      object: nil)
    profileImageButton.layer.cornerRadius = 90
    profileImageButton.layer.borderWidth = 0.5
    profileImageButton.layer.borderColor = UIColor.black.cgColor
  }

  @IBAction func onClick(_ sender: Any) {
    Login()
  }
    
  @IBAction func tappedProfileImageButton(_ sender: Any) {
    tappedProfileImageButton()
  }

  private func tappedProfileImageButton() {
    let imagePickerController = UIImagePickerController()
    imagePickerController.delegate = self
    imagePickerController.allowsEditing = true
    self.present(imagePickerController, animated: true, completion: nil)
  }

  private func firestoragePutData() {
    guard let image = profileImageButton.imageView?.image else { return }
    guard let uploadImage = image.jpegData(compressionQuality: 0.3) else { return }
    FSUser.firestoragePutData(uploadImage: uploadImage)
  }

  @objc func showKeyboard(notification: Notification) {
    let keyboardFrame =
      (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
    guard let keyboardMinY = keyboardFrame?.minY else { return }
    let logInButtonMaxY = loginButton.frame.maxY
    let distance = logInButtonMaxY - keyboardMinY + 20

    let transform = CGAffineTransform(translationX: 0, y: -distance)

    UIView.animate(
      withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [],
      animations: { self.view.transform = transform })

    //print(":", keyboardMinY, ":", logInButtonMaxY)
  }
  @objc func hideKeyboard() {
    UIView.animate(
      withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [],
      animations: { self.view.transform = .identity })
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    self.view.endEditing(true)
  }

  private func Login() {
    let email = idTextField.text
    let password = pwTextField.text
    if email!.isEmpty && password!.isEmpty {
      error(title: "エラー", message: "IDかPWが入力されていません")
    } else if email!.isEmpty {
      error(title: "エラー", message: "IDが入力されていません")
    } else if password!.isEmpty {
      error(title: "エラー", message: "PWが入力されていません")
    } else {
        FSUser.LoginUser(email: email!, password: password!)
    }
  }

  private func error(title: String, message: String) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

    let confirmAction: UIAlertAction = UIAlertAction(
      title: "confirm", style: .default,
      handler: { (action: UIAlertAction) in
        print("confirm")
      })

    alertController.addAction(confirmAction)

    present(alertController, animated: true, completion: nil)
  }

  private func createUserToFirestore(profileImageUrl: String) {
    let userName = userNameTextField.text ?? "無名"
    let userId = FSUser.getUserId()
    FSUser.createToFirestore(userName: userName, profileImageUrl: profileImageUrl)
    let userViewModel = UserViewModel()
    userViewModel.initialize()
    userViewModel.setUser(uid: userId, userName: userName, profileImageUrl: profileImageUrl)
  }
}

extension LoginViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
