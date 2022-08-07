//
//  FirestoreConst.swift
//  FavoriteLinks
//
//  Created by 田中裕貴 on 2021/01/31.
//  Copyright © 2021 田中裕貴. All rights reserved.
//

import Foundation

struct FirestoreConst {
    struct CollectionNames {
        static let users = "users"
        static let rooms = "rooms"
        static let messages = "messages"
        static let urlList = "urlList"
    }
    struct UsersFieldNames {
        static let uid = "uid"
        static let userName = "userName"
        static let profileImageUrl = "profileImageUrl"
    }
    struct RoomsFieldNames {
        static let name = "name"
        static let userIds = "userIds"
    }
    struct MessagesFieldNames {
        static let date = "date"
        static let message = "message"
        static let userId = "userId"
    }
    struct UrlListFieldNames {
        static let title = "title"
        static let url = "url"
    }
}
