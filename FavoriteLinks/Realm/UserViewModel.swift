//
//  UserViewModel.swift
//  FavoriteLinks
//
//  Created by 田中裕貴 on 2021/02/28.
//  Copyright © 2021 田中裕貴. All rights reserved.
//

import RealmSwift

class UserViewModel {
  var realmObject: Realm?
  public func initialize() {
    realmObject = try! Realm()
    print(Realm.Configuration.defaultConfiguration.fileURL!)
  }
  public func setUser(uid: String, userName: String, profileImageUrl: String) {
    let userModel = UserModel(uid: uid, userName: userName, profileImageUrl: profileImageUrl)
    try! realmObject?.write {
      realmObject?.add(userModel)
    }
  }
  public func getUsers() -> Results<UserModel> {
    let userModel = realmObject!.objects(UserModel.self)
    return userModel
  }
  public func getUserInfo() -> UserModel? {
    let userModels = realmObject!.objects(UserModel.self)
    return userModels.count > 0 ? userModels[0] : nil
  }
}
