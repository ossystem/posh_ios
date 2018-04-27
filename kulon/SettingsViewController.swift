//
//  SettingsViewController.swift
//  kulon
//
//  Created by Артмеий Шлесберг on 07/05/2017.
//  Copyright © 2017 Jufy. All rights reserved.
//

import Foundation
import UIKit
import Branch
import RxSwift

struct SettingItem {
    
    var name: String
    var descr: String
    var image: UIImage
    var request: URLRequest?
    
    static var defaultSettingsSet: [SettingItem] {
        return [
//            SettingItem(name: "ОТВЯЗАТЬ КУЛОН", descr: "Изменить кулон, управляемый с помощью приложения", image: #imageLiteral(resourceName: "icon_settigns_kulon_8F8D8D"),request: nil),
            SettingItem(name: "Contacts", descr: "Write a letter to the developers", image: #imageLiteral(resourceName: "icon_settings_contacts_8F8D8D"),request: ContactsSettingsService().getRequest() ),
            SettingItem(name: "FAQ", descr: "The most frequently asked questions", image: #imageLiteral(resourceName: "icon_settings_question_8F8D8D"), request: nil),
            SettingItem(name: "Store locations", descr: "Find the closest store to buy our gear", image: #imageLiteral(resourceName: "icon_settings_geo_8F8D8D"), request:AdressesSettingsService().getRequest()),
            SettingItem(name: "Share", descr: "Share your personal link with friends to achive tokens", image: #imageLiteral(resourceName: "icon-share"), request: nil),
            SettingItem(name: "LOGOUT", descr: "", image: #imageLiteral(resourceName: "icon_settings_logout"), request: nil),
            
        ]
    }
}




class SettingsViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    enum SettingsItems: Int {
        case contacts, FAQ, adresses, share, logout
        
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
    private var disposeBag = DisposeBag()
    
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
        case .share:
            shareLink()
        case .logout:
            LoginService().logout()
        default:
            //TODO: open culon connecting screen
            return
        }
    }
    
    var referralService = GetRefferalApiService()
    
    func shareLink() {
        
        referralService.request(parameter: ParameterNone())
            .subscribe(onNext: {
                let buo = BranchUniversalObject(canonicalIdentifier: "referral")
                let lp = BranchLinkProperties()
                lp.addControlParam("referral_code", withValue: $0.refferalCode)
                buo.showShareSheet(with: lp, andShareText: "Install this awesome app", from: self) { (activityType, completed) in
                    print(activityType ?? "")
                }
            }).disposed(by: disposeBag)

    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Identifiers.Segue.SettingsWebViewControllerID,
            let webController = segue.destination as? SettingsWebViewController, let item = sender as? SettingsItems {
            webController.request = item.item.request
        }
    }
    
}
