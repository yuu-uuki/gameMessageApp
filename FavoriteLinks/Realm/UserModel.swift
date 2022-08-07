//
//  UserModel.swift
//  FavoriteLinks
//
//  Created by 田中裕貴 on 2021/02/28.
//  Copyright © 2021 田中裕貴. All rights reserved.
//

import RealmSwift

class UserModel: Object {
  @objc dynamic var _id: ObjectId = ObjectId.generate()
  @objc dynamic var id = 1
  @objc dynamic var uid: String = ""
  @objc dynamic var userName: String = ""
  @objc dynamic var profileImageUrl: String = ""
  override static func primaryKey() -> String? {
    return "_id"
  }
  convenience init(uid: String, userName: String, profileImageUrl: String) {
    self.init()
    self.uid = uid
    self.userName = userName
    self.profileImageUrl = profileImageUrl
  }
}
