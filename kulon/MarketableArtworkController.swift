//
// Created by Артмеий Шлесберг on 23/03/2018.
// Copyright (c) 2018 Jufy. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import SnapKit

class MarketableArtworkController: UIViewController {

    private var artwork: MarketableArtwork
    private var infoView: ArtworkInfoView

    private var disposeBag = DisposeBag()
    
    private var topButton = RoundedButton()
        .with(image: #imageLiteral(resourceName: "icon_top_cancel"))
        .with(tintColor: UIColor.Kulon.orange)
    
    init(marketableArtwork: MarketableArtwork) {
        self.artwork = marketableArtwork
        self.infoView = ArtworkInfoView(artwork: marketableArtwork)
        super.init(nibName: nil, bundle: nil)
        let topBG = TopBarBackgroundView()
        topBG.backgroundColor = .clear
        view.addSubviews([infoView, topBG, topButton])
        infoView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        topBG.snp.makeConstraints { [unowned self] in
            $0.trailing.leading.equalToSuperview()
            $0.top.equalTo(self.topLayoutGuide.snp.bottom)
            $0.height.equalTo(70)
        }
        topButton.snp.makeConstraints { [unowned self] in
            $0.centerX.equalToSuperview()
            $0.top.equalTo(self.topLayoutGuide.snp.bottom).offset(20)
            $0.width.height.equalTo(40)
        }
        
        topButton.rx.tap.subscribe(onNext: { [unowned self] in
            self.navigationController?.popViewController(animated: true)
        }).disposed(by: disposeBag)
        
        infoView.wantsToAqcuire
            .flatMap { [unowned self] in
                self.artwork.acquire()
                //TODO: make waiting
            }
            .subscribe(onNext: { [unowned self] in
                self.present(ArtworkAcquisitionController(acquisition: $0, artwork: marketableArtwork as! MarketableArtwork), animated: true)
            }).disposed(by: disposeBag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
}


class OwnedArtworkController: UIViewController {

    private var artwork: OwnedArtwork
    private var infoView: ArtworkInfoView

    private var disposeBag = DisposeBag()

    private var topButton = RoundedButton()
        .with(image: #imageLiteral(resourceName: "icon_top_cancel"))
        .with(tintColor: UIColor.Kulon.orange)

    init(ownedArtwork: OwnedArtwork) {
        self.artwork = ownedArtwork
        self.infoView = ArtworkInfoView(artwork: ownedArtwork)
        super.init(nibName: nil, bundle: nil)
        let topBG = TopBarBackgroundView()
        topBG.backgroundColor = .clear
        view.addSubviews([infoView, topBG, topButton])
        infoView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        topBG.snp.makeConstraints { [unowned self] in
            $0.trailing.leading.equalToSuperview()
            $0.top.equalTo(self.topLayoutGuide.snp.bottom)
            $0.height.equalTo(70)
        }
        topButton.snp.makeConstraints { [unowned self] in
            $0.centerX.equalToSuperview()
            $0.top.equalTo(self.topLayoutGuide.snp.bottom).offset(20)
            $0.width.height.equalTo(40)
        }

        topButton.rx.tap.subscribe(onNext: { [unowned self] in
            self.navigationController?.popViewController(animated: true)
        }).disposed(by: disposeBag)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.isNavigationBarHidden = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }

}

class ArtworkInfoView: UIView {

    private var artworkImage = KulonImageView()
        .with(roundedEdges: 272/2)
        .with(contentMode: .scaleAspectFill)
        .with(backgroundColor: .gray)
    private var artistImage = UIImageView()
        .with(roundedEdges: 32/2)
        .with(contentMode: .scaleAspectFill)
        .with(backgroundColor: .gray)
    private var artistName = StandardLabel(font: .systemFont(ofSize: 20))
        .aligned(by: .center)
    private var artworkName = StandardLabel(font: .systemFont(ofSize: 24))
        .aligned(by: .center)
    private var price = StandardLabel(font: .systemFont(ofSize: 16))
        .aligned(by: .center)
    private var buyButton = UIButton()
        .with(title: "Buy")
        .with(titleColor: .white)
        .with(backgroundColor: UIColor.Kulon.lightOrange)
        .with(roundedEdges: 8)
    private var likeButton = UIButton()
    private var downloadButton = UIButton()
        .with(title: "Download")
        .with(titleColor: .white)
        .with(backgroundColor: UIColor.Kulon.lightOrange)
        .with(roundedEdges: 8)
    private var disposeBag = DisposeBag()
    private var request: URLRequest?
    private var artwork: Artwork & Purchasable
    private var bleService = BLEService()
    
    var wantsToAqcuire: Observable<Void> {
        return buyButton.rx.tap.asObservable()
    }
    
    var wantsToLike: Observable<Void> {
        return likeButton.rx.tap.asObservable()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        artworkImage.layer.cornerRadius = artworkImage.frame.width/2
    }
    
    init(artwork: Artwork & Purchasable) {
        self.artwork = artwork
        super.init(frame: .zero)
        [artistImage, artworkImage, artistName, artworkName, price, buyButton, likeButton, downloadButton]
                .forEach { [unowned self] in self.addSubview($0) }
        ([artistImage, artworkImage, artistName, artworkName, price, buyButton] as [UIView])
            .forEach {
                $0.snp.makeConstraints {
                    $0.centerX.equalToSuperview()
                }
            }
        backgroundColor = .white
        
        downloadButton.snp.makeConstraints {
            $0.edges.equalTo(buyButton)
        }
        
        downloadButton.isHidden = true
        
        artworkImage.setBelow(view: artistImage, offset: 16)
        artistImage.setBelow(view: artistName, offset: 16)
        artistName.setBelow(view: artworkName, offset: 20)
        artworkName.setBelow(view: price, offset: 4)
        
        artworkImage.snp.makeConstraints {
            $0.top.equalToSuperview().offset(109)
            $0.leading.equalToSuperview().offset(52)
            $0.trailing.equalToSuperview().inset(52)
            $0.height.equalTo(artworkImage.snp.width)
        }
        
        artistImage.snp.makeConstraints {
            $0.width.height.equalTo(32)
        }
        
        buyButton.snp.makeConstraints {
            $0.height.equalTo(36)
            $0.width.equalTo(268)
            $0.bottom.equalToSuperview().inset(60)
        }

        
        artwork.info.subscribe(onNext: { [unowned self] info  in
            self.artistName.text = info.artist.name
            self.artworkName.text = info.name
            self.price.text = "\(info.minPrice)POS"
            self.request = try? URLRequest(url: URL(string: info.image.link)!, method: .get, headers: ["Authorization": "Bearer \(TokenService().token!)"])
            if let request = self.request {
                self.artworkImage.setImage(with: request)
            } else {
                print("image request error: \n\turl: \(info.image.link)")
            }
        }).disposed(by: disposeBag)
        
        artwork.purchased.subscribe(onNext: {
            self.buyButton.isHidden = true
            self.downloadButton.isHidden = false
        }).disposed(by: disposeBag)
        
        if let owned = artwork as? OwnedArtwork {
            downloadButton.rx.tap.asObservable()
            .do(onNext: {
                self.downloadButton.setWaiting(true)
            })
            .flatMap { return owned.setToDevice() }
            .debug()
            .subscribe(onNext: { [unowned self] in
                self.downloadButton.setWaiting(false)
            })
            .disposed(by: disposeBag)
        }
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}

