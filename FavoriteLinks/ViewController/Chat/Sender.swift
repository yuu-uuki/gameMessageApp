//
//  Sender.swift
//  FavoriteLinks
//
//  Created by 田中裕貴 on 2020/11/15.
//  Copyright © 2020 田中裕貴. All rights reserved.
//

import Foundation
import MessageKit

class Sender: SenderType {
    
  var senderId: String = ""
  var displayName: String = ""
    
  init(senderId: String, displayName: String) {
    self.senderId = senderId
    self.displayName = displayName
  }
}
