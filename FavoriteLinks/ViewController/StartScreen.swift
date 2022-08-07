//
//  StartScreen.swift
//  FavoriteLinks
//
//  Created by 田中裕貴 on 2020/12/05.
//  Copyright © 2020 田中裕貴. All rights reserved.
//

import FirebaseAuth
import UIKit
import Lottie

class StartScreen: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func viewDidAppear(_ animated: Bool) {
    let userViewModel = UserViewModel()
    userViewModel.initialize()
    if Auth.auth().currentUser != nil && userViewModel.getUsers().count > 0 {
      performSegue(withIdentifier: "tabSegue", sender: nil)
    } else {
      performSegue(withIdentifier: "loginSegue", sender: nil)
    }
  }
}
