//
// Created by Артмеий Шлесберг on 23/03/2018.
// Copyright (c) 2018 Jufy. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import SnapKit
import FLAnimatedImage
import SDWebImage

class MarketableArtworkController: UIViewController, UIGestureRecognizerDelegate {

    private var artwork: MarketableArtwork
    private var infoView: ArtworkInfoView

    private var disposeBag = DisposeBag()
    
    private var topButton = RoundedButton()
        .with(image: #imageLiteral(resourceName: "icon_top_cancel"))
        .with(tintColor: UIColor.Kulon.orange)
    
    var wantsToShowArtist: Observable<Artist> {
        return infoView.wantToShowArtist
    }
    
    private let recoverSubject = PublishSubject<Void>()
    private let errorSubject = PublishSubject<Error>()
    private let purchaseSubject = PublishSubject<Void>()
    
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
                self.present(ArtworkAcquisitionController(acquisition: $0, artwork: marketableArtwork), animated: true)
            }).disposed(by: disposeBag)
        
        Recoverable(origin:
            infoView.wantsToAqcuire
                .flatMap { [unowned self] in
                    self.artwork.acquire()
                    //TODO: make waiting
            }
            ,
                    recoveringOn: recoverSubject,
                    reportingErrorsTo: errorSubject
            )
            .debug()
            .subscribe(onNext: { [unowned self] in
                self.present(ArtworkAcquisitionController(acquisition: $0, artwork: marketableArtwork), animated: true)
            }).disposed(by: disposeBag)
            
        infoView.wantsToAqcuire
            .withLatestFrom(errorSubject)
            .debug()
            .map { _ in}
            .bind(to: recoverSubject)
            .disposed(by: disposeBag)
        
        
        
        infoView.wantToShowArtist.subscribe(onNext: {
            (self.tabBarController as? TabBarController)?.showArtist($0)
        }).disposed(by: disposeBag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isNavigationBarHidden = true
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
}


class OwnedArtworkController: UIViewController {

    private var artwork: OwnedArtwork
    private var infoView: ArtworkInfoView

    private var disposeBag = DisposeBag()

    private var topButton = RoundedButton()
        .with(image: #imageLiteral(resourceName: "icon_top_cancel"))
        .with(tintColor: UIColor.Kulon.orange)
    
    var wantsToShowArtist: Observable<Artist> {
        return infoView.wantToShowArtist
    }

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

        infoView.wantToShowArtist.subscribe(onNext: {
            (self.tabBarController as? TabBarController)?.showArtist($0)
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

    private var artworkImage = FLAnimatedImageView()
        .with(roundedEdges: 272/2)
        .with(contentMode: .scaleAspectFill)
    
    private var artistImage = UIImageView()
        .with(roundedEdges: 32/2)
        .with(contentMode: .scaleAspectFill)
    
    private var artistName = UIButton()
        .with(font: .systemFont(ofSize: 18, weight: UIFontWeightBold))
        .with(titleColor: .black)
    .with(backgroundColor: .white)
    
    private var artworkName = StandardLabel(font: .systemFont(ofSize: 26, weight: UIFontWeightBold))
        .aligned(by: .center)
    
    private var price = StandardLabel(font: .systemFont(ofSize: 16))
        .aligned(by: .center)
    
    private var buyButton = StandardButton()
        .with(title: "Buy")
        .with(titleColor: .black)
        .with(backgroundColor: UIColor.Kulon.lightOrange)
        .with(roundedEdges: 8)
    
    private var likeButton = UIButton()
        .with(image: #imageLiteral(resourceName: "icon_like_1"))
        .with(roundedEdges: 16)
    
    private var downloadButton = StandardButton()
        .with(title: "Put on")
        .with(titleColor: .black)
        .with(backgroundColor: UIColor.Kulon.lightOrange)
        .with(roundedEdges: 8)
    
    private var disposeBag = DisposeBag()
    private var request: URLRequest?
    private var artwork: Artwork & Purchasable
    private var bleService = BLEService()
    
    var wantsToAqcuire: Observable<Void> {
        return buyButton.rx.tap.asObservable()
    }
    
    private let recoverSubject = PublishSubject<Void>()
    private let errorSubject = PublishSubject<Error>()
    private let purchaseSubject = PublishSubject<Void>()
    
    private var artistSubject = PublishSubject<Artist>()
    var wantToShowArtist: Observable<Artist> {
        return Observable.combineLatest(artistSubject.debug(), artistName.rx.tap.asObservable().debug())
            .map { $0.0 }

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        artworkImage.layer.cornerRadius = artworkImage.frame.width/2
    }
    
    init(artwork: Artwork & Purchasable) {
        self.artwork = artwork

        super.init(frame: .zero)
        
        let underline = UIView().with(backgroundColor: .black)
        [artistImage, artworkImage, artistName, artworkName, price, buyButton, likeButton, downloadButton, underline]
                .forEach { [unowned self] in self.addSubview($0) }
        ([artistImage, artworkImage, artistName, artworkName, price, buyButton, underline] as [UIView])
            .forEach {
                $0.snp.makeConstraints {
                    $0.centerX.equalToSuperview()
                }
            }
        backgroundColor = .white
        
        downloadButton.snp.makeConstraints {
            $0.edges.equalTo(buyButton)
        }
        
        artistImage.tintColor = .black
        likeButton.tintColor = UIColor.Kulon.lightOrange
        
        downloadButton.isHidden = !artwork.isPurchased
        buyButton.isHidden = artwork.isPurchased
        
        likeButton.setImage(artwork.isLiked ? #imageLiteral(resourceName: "icon_like_2") : #imageLiteral(resourceName: "icon_like_1"), for: .normal)
        
        artworkImage.setBelow(view: artistImage, offset: 16)
        artistImage.setBelow(view: artistName, offset: 8)
        artistName.setBelow(view: artworkName, offset: 16)
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
            $0.bottom.equalToSuperview().inset(80)
        }
        
        likeButton.snp.makeConstraints {
            $0.top.equalTo(artworkImage)
            $0.trailing.equalTo(artworkImage)
            $0.width.height.equalTo(32)
        }
        
        artistName.snp.makeConstraints {
            $0.height.equalTo(24)
        }
        
        underline.snp.makeConstraints {
            $0.top.equalTo(artistName.snp.bottom)
            $0.trailing.equalTo(artistName)
            $0.leading.equalTo(artistName).offset(32)
            $0.height.equalTo(1)
        }

        self.buyButton.isEnabled = false

        
        artwork.info.subscribe(onNext: { [unowned self] info  in
            self.buyButton.isEnabled = true
            self.artistName.setTitle("by \(info.artist.name)", for: .normal)
            self.artworkName.text = info.name
            self.buyButton.setTitle("Buy (\(info.minPrice) POSH)", for: .normal)
        
            self.artworkImage.sd_setImage(with: URL(string: info.image.link)!)

            info.artist.avatar.asObservable().bind(to:
                self.artistImage.rx.image
            ).disposed(by: self.disposeBag)
            self.artistSubject.onNext(info.artist)
        }).disposed(by: disposeBag)
        
        
        artwork.purchased.subscribe(onNext: {
            self.buyButton.isHidden = true
            self.downloadButton.isHidden = false
        }).disposed(by: disposeBag)
        
        Recoverable(origin:
            downloadButton.rx.tap
                .do(onNext: {
                    self.downloadButton.setWaiting(true)
                })
                .flatMap {
                    OwnedArtworkFromArtwork(artwork: artwork).setToDevice()
                }.do(onNext: {
                    self.downloadButton.setWaiting(false)
                })
            ,
                    recoveringOn: recoverSubject,
                    reportingErrorsTo: errorSubject
            )
            .debug()
            .subscribe(onNext: { [unowned self] in
                self.downloadButton.setWaiting(false)
                }, onError: { [unowned self] _ in
                    self.downloadButton.setWaiting(false)
            })
            .disposed(by: disposeBag)
        errorSubject.subscribe(onNext: { [unowned self] _ in
            self.downloadButton.setWaiting(false)
        }).disposed(by: disposeBag)
        
        downloadButton.rx.tap.asObservable()
            .withLatestFrom(errorSubject)
            .debug()
            .map { _ in}
            .bind(to: recoverSubject)
            .disposed(by: disposeBag)
        
//
//        downloadButton.rx.tap.asObservable()
//            .do(onNext: {
//                self.downloadButton.setWaiting(true)
//            })
//        .flatMap {
//            OwnedArtworkFromArtwork(artwork: artwork).setToDevice()
//            }
//
//        .debug()
//        .subscribe(onNext: { [unowned self] in
//            self.downloadButton.setWaiting(false)
//            }, onError: { [unowned self] _ in
//                self.downloadButton.setWaiting(false)
//        })
//        .disposed(by: disposeBag)
        
        
        likeButton.rx.tap.asObservable()
            .flatMap {
            artwork.like()
        }
            .subscribe(onNext: { [unowned self] in
                self.likeButton.setImage($0 ? #imageLiteral(resourceName: "icon_like_2") : #imageLiteral(resourceName: "icon_like_1"), for: .normal)
            })
        .disposed(by: disposeBag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}


