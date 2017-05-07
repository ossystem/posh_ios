//
//  SettingsCell.swift
//  kulon
//
//  Created by Артмеий Шлесберг on 07/05/2017.
//  Copyright © 2017 Jufy. All rights reserved.
//

import Foundation
import UIKit

class  SettingsCell: UITableViewCell {
    
    @IBOutlet weak var icon: RoundedImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    
    func configure(with settingsItem: SettingItem) {
        icon.image = settingsItem.image
        title.text = settingsItem.name
        subtitle.text = settingsItem.descr
    }
    
}
