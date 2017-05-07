//
//  SettingsViewController.swift
//  kulon
//
//  Created by Артмеий Шлесберг on 07/05/2017.
//  Copyright © 2017 Jufy. All rights reserved.
//

import Foundation
import UIKit

struct SettingItem {
    var name: String
    var descr: String
    var image: UIImage
    
    static var defaultSettingsSet: [SettingItem] {
        //TODO: change items
        return [
            SettingItem(name: "ОТВЯЗАТЬ КУЛОН", descr: "Изменить кулон, управляемый с помощью приложения", image: #imageLiteral(resourceName: "logo")),
            SettingItem(name: "ОТВЯЗАТЬ КУЛОН", descr: "Изменить кулон, управляемый с помощью приложения", image: #imageLiteral(resourceName: "logo")),
            SettingItem(name: "ОТВЯЗАТЬ КУЛОН", descr: "Изменить кулон, управляемый с помощью приложения", image: #imageLiteral(resourceName: "logo")),
            SettingItem(name: "ОТВЯЗАТЬ КУЛОН", descr: "Изменить кулон, управляемый с помощью приложения", image: #imageLiteral(resourceName: "logo"))
        ]
    }
}

class SettingsViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
    var settings = SettingItem.defaultSettingsSet
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 70, left: 0, bottom: 0, right: 0)
    }
    
    //MARK: - tableView data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell") as! SettingsCell
        cell.configure(with: settings[indexPath.row])
        return cell
    }
    
}
