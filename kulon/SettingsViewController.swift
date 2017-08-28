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
    var request: URLRequest?
    
    static var defaultSettingsSet: [SettingItem] {
        return [
            SettingItem(name: "ОТВЯЗАТЬ КУЛОН", descr: "Изменить кулон, управляемый с помощью приложения", image: #imageLiteral(resourceName: "icon_settigns_kulon_8F8D8D"),request: nil),
            SettingItem(name: "КОНТАКТЫ", descr: "Написать разработчику и задать свой вопрос", image: #imageLiteral(resourceName: "icon_settings_contacts_8F8D8D"),request: ContactsSettingsService().getRequest() ),
            SettingItem(name: "ВОПРОСЫ И ОТВЕТЫ", descr: "Ответы на самые распространенные вопросы", image: #imageLiteral(resourceName: "icon_settings_question_8F8D8D"), request: nil),
            SettingItem(name: "АДРЕСА МАГАЗИНОВ", descr: "Изменить кулон, управляемый с помощью приложения", image: #imageLiteral(resourceName: "icon_settings_geo_8F8D8D"), request:AdressesSettingsService().getRequest()),
            SettingItem(name: "ВЫЙТИ", descr: "", image: #imageLiteral(resourceName: "icon_settings_logout"), request: nil)
        ]
    }
}




class SettingsViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    enum SettingsItems: Int {
        case deattachKulon = 0, contacts, FAQ, adresses, logout
        
        var item: SettingItem {
           return SettingItem.defaultSettingsSet[rawValue]
        }
    }
    
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
        tableView.tableFooterView = UIView() //hack to remove emty cells
    }
    
    //MARK: - tableView data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.Cell.settingsCell) as! SettingsCell
        cell.configure(with: settings[indexPath.row])
        return cell
    }
    
    //MARK: - tableView delegate 
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = SettingsItems(rawValue: indexPath.row)!
        switch item {
        case .adresses,.contacts:
            performSegue(withIdentifier: Identifiers.Segue.SettingsWebViewControllerID, sender: item)
        case .FAQ:
            performSegue(withIdentifier: Identifiers.Segue.FAQViewController, sender: nil)
        case .logout:
            LoginService().logout()
        default:
            //TODO: open culon connecting screen
            return
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Identifiers.Segue.SettingsWebViewControllerID,
            let webController = segue.destination as? SettingsWebViewController, let item = sender as? SettingsItems {
            webController.request = item.item.request
        }
    }
    
}
