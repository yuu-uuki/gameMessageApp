//
//  CustomTableViewCell.swift
//  FavoriteLinks
//
//  Created by 田中裕貴 on 2020/12/30.
//  Copyright © 2020 田中裕貴. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
  @IBOutlet weak var roomBackgroundImage: UIImageView!
  @IBOutlet weak var roomNameLabel: UILabel!

  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)

    // Configure the view for the selected state
  }

}
