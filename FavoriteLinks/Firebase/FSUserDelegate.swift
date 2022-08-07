//
//  FirebaseProtocol.swift
//  FavoriteLinks
//
//  Created by 田中裕貴 on 2021/01/17.
//  Copyright © 2021 田中裕貴. All rights reserved.
//

import Foundation

protocol FSUserSigninDelegate {
    // ログインが成功した時に呼ばれる
    func onCreateSucceeded()
    // ログインが失敗した時に呼ばれる
    func onLoginFailed(message: String)
}

protocol FSUserLoginDelegate {
    // ログインが成功した時に呼ばれる
    func onLoginSucceeded()
    // ログインが失敗した時に呼ばれる
    func onLoginFailed(message: String)
    
    func createToFirestore(profileImageUrl: String)
}
