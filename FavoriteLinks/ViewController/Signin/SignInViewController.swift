//
//  LoginViewController.swift
//  FavoriteLinks
//
//  Created by 田中裕貴 on 2020/08/09.
//  Copyright © 2020 田中裕貴. All rights reserved.
//

import Firebase
import FirebaseAuth
import UIKit

class SignInViewController: UIViewController, UITextFieldDelegate, FSUserSigninDelegate {
    
    func onCreateSucceeded() {
        self.performSegue(withIdentifier: "logIn", sender: nil)
    }
    
    func onLoginFailed(message: String) {
        self.error(title: "エラー", message: message)
    }
    
  @IBOutlet weak var getId: UITextField!
  @IBOutlet weak var getPw: UITextField!
  @IBOutlet weak var signInButton: UIButton!

  @IBAction func onClick(_ sender: Any) {
    handleAuthToFirebase()
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    FSUser.fsUserSigninDelegate = self
    
    signInButton.layer.cornerRadius = 10

    NotificationCenter.default.addObserver(
      self, selector: #selector(showKeyboard), name: UIResponder.keyboardWillShowNotification,
      object: nil)
    NotificationCenter.default.addObserver(
      self, selector: #selector(hideKeyboard), name: UIResponder.keyboardWillHideNotification,
      object: nil)
  }

  @objc func showKeyboard(notification: Notification) {
    let keyboardFrame =
      (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
    guard let keyboardMinY = keyboardFrame?.minY else { return }
    let signInButtonMaxY = signInButton.frame.maxY
    let distance = signInButtonMaxY - keyboardMinY + 20

    let transform = CGAffineTransform(translationX: 0, y: -distance)

    UIView.animate(
      withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [],
      animations: { self.view.transform = transform })

    //print(":", keyboardMinY, ":", signInButtonMaxY)
  }

  @objc func hideKeyboard() {
    UIView.animate(
      withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [],
      animations: { self.view.transform = .identity })
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    self.view.endEditing(true)
  }

  private func handleAuthToFirebase() {
    guard let email = getId.text else { return }
    guard let password = getPw.text else { return }

    if email.isEmpty && password.isEmpty {
      error(title: "エラー", message: "IDかPWが入力されていません")
    } else if email.isEmpty {
      error(title: "エラー", message: "IDが入力されていません")
    } else if password.isEmpty {
      error(title: "エラー", message: "PWが入力されていません")
    } else {
      FSUser.createUser(email: email, password: password)
    }
    /*
         enum resultCode {
         success, // 0
         error, // 1
         warning // 2
         }

         var a = resultCode.success
         switch a {
         case .success:
         break
         case .error:
         break
         case .warning:
         break
         case 3:
         break
         default:
         //
         }
         */

  }

  func error(title: String, message: String) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

    let confirmAction = UIAlertAction(
      title: "confirm", style: .default,
      handler: { (action: UIAlertAction) in
        print("confirm")
      })
    alertController.addAction(confirmAction)
    present(alertController, animated: true, completion: nil)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }

  /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */

}
