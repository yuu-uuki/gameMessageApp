//
//  UrlTableViewCell.swift
//  FavoriteLinks
//
//  Created by 田中裕貴 on 2021/01/05.
//  Copyright © 2021 田中裕貴. All rights reserved.
//

import UIKit

class UrlTableViewCell: UITableViewCell {

  @IBOutlet weak var UrlLabel: UILabel!
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)

    // Configure the view for the selected state
  }

}
