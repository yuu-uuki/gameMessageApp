//
//  MypageViewController.swift
//  FavoriteLinks
//
//  Created by 田中裕貴 on 2020/12/13.
//  Copyright © 2020 田中裕貴. All rights reserved.
//

import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import UIKit

class MypageViewController: UIViewController {

  @IBOutlet weak var editProfile: UIButton!
  @IBOutlet weak var profileImage: UIImageView!
  @IBOutlet weak var userName: UILabel!
  let db = Firestore.firestore()
  let storage = Storage.storage()
  let uid = Auth.auth().currentUser!.uid as String

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    editProfile.layer.cornerRadius = 10
    profileImage.layer.cornerRadius = 90
    getProfileInfo(uid: uid)
  }

  @IBAction func editProfile(_ sender: Any) {
    let storyboard: UIStoryboard = UIStoryboard(name: "Tab", bundle: nil)
    let nextView = storyboard.instantiateViewController(withIdentifier: "EditMypage")
    nextView.modalPresentationStyle = .fullScreen
    self.present(nextView, animated: true, completion: nil)
  }

  @IBAction func logoutClick(_ sender: Any) {
    let alertController = UIAlertController(
      title: "ログアウトしますか？", message: "", preferredStyle: .alert)
    let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { action -> Void in
    }
    let logoutAction = UIAlertAction(title: "ログアウト", style: .default) { action -> Void in
      do {
        try Auth.auth().signOut()
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let nextView = storyboard.instantiateViewController(withIdentifier: "login")
        nextView.modalPresentationStyle = .fullScreen
        self.present(nextView, animated: true, completion: nil)
      } catch let signOutError as NSError {
        print("SignOut Error: %@", signOutError)
      }
    }
    alertController.addAction(logoutAction)
    alertController.addAction(cancelAction)
    present(alertController, animated: true, completion: nil)
  }

  func getProfileInfo(uid: String) {
//    let userViewModel = UserViewModel()
//    userViewModel.initialize()
//    let userInfo = userViewModel.getUserInfo()
//    let uid = userInfo.uid
    let docRef = db.collection("users").document(uid)
    docRef.getDocument { (document, err) in
      if let document = document, document.exists {
        let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
        print("Document data: \(dataDescription)")
        let profileImageUrl = document.data()!["profileImageUrl"] as? String
        let userName = document.get("userName") as! String
        self.userName.text = userName
        if let profileImageUrl = profileImageUrl {
          do {
            let data = try Data(contentsOf: URL(string: profileImageUrl)!)
            self.profileImage.image = UIImage(data: data)
            self.profileImage.contentMode = .scaleAspectFill
          } catch _ {
            self.profileImage.image = UIImage()
          }
        } else {
          self.profileImage.image = UIImage()
        }
      } else {
        print("Document does not exist")
      }
    }
  }
}
