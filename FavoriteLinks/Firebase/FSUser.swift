//
//  Firestore.swift
//  FavoriteLinks
//
//  Created by 田中裕貴 on 2021/01/17.
//  Copyright © 2021 田中裕貴. All rights reserved.
//

import Firebase
import Foundation

class FSUser {
    static let auth = Auth.auth()
    static let storage = Storage.storage()
    static let db = Firestore.firestore()
    static let uid = Auth.auth().currentUser!.uid as String
    
    public static var fsUserSigninDelegate: FSUserSigninDelegate?
    
    public static func createUser(email: String, password: String) {
        auth.createUser(withEmail: email, password: password) { authResult, err in
          if err == nil {
            Auth.auth().currentUser?.sendEmailVerification { (error) in
                fsUserSigninDelegate!.onLoginFailed(message: "既にログインされています")
            }
            fsUserSigninDelegate!.onCreateSucceeded()
            return
          } else {
            if let e = err as NSError? {
              switch AuthErrorCode(rawValue: e.code) {
              case .emailAlreadyInUse:
                fsUserSigninDelegate!.onLoginFailed(message: "既にログインされています")
                break
              default:
                break
              }
            }
          }
        }
    }
    
    public static var fsUserLoginDelegate: FSUserLoginDelegate?
    
    public static func LoginUser(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
          if error == nil {
            if !Auth.auth().currentUser!.isEmailVerified {
                fsUserLoginDelegate!.onLoginFailed(message: "メール認証が完了してません")
              return
            }
            fsUserLoginDelegate!.onLoginSucceeded()
            print("ログインしました")
            return
          } else {
            if let e = error as NSError? {
              switch AuthErrorCode(rawValue: e.code) {
              case .emailAlreadyInUse:
                fsUserLoginDelegate!.onLoginFailed(message: "既にログインしています")
                break
              default:
                break
              }
            }
            print("ログインに失敗しました")
          }
        }
    }
    
    public static func firestoragePutData(uploadImage: Data) {
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
            guard let urlString = url?.absoluteString else { return }
            print("urlString: ", urlString)
            fsUserLoginDelegate?.createToFirestore(profileImageUrl: urlString)
          }
        }
    }
    
    public static func createToFirestore(userName: String, profileImageUrl: String) {
        let uid = Auth.auth().currentUser!.uid as String
        var ref: DocumentReference? = nil
        ref = self.db.collection(FirestoreConst.CollectionNames.users).document(uid)
        ref?.setData([
            FirestoreConst.UsersFieldNames.userName: userName,
            FirestoreConst.UsersFieldNames.uid: uid,
            FirestoreConst.UsersFieldNames.profileImageUrl: profileImageUrl,
        ]) { err in
          if let err = err {
            print("Error adding document: \(err)")
          } else {
            print("Document added with ID: \(ref!.documentID)")
          }
        }
    }
  public static func getUserId() -> String {
    return Auth.auth().currentUser!.uid as String
  }
}
