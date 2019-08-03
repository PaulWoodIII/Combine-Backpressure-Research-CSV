//
//  NameCollectionViewCell.swift
//  NameList
//
//  Created by Paul Wood on 8/2/19.
//  Copyright © 2019 Paul Wood. All rights reserved.
//

import UIKit

class NameCollectionViewCell: UICollectionViewCell {
  
  static let reuseIdentifier = "NameCollectionViewCell"
  
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var genderLabel: UILabel!
  @IBOutlet weak var countLabel: UILabel!
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
}
