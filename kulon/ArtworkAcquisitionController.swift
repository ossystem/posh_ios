//
//  ArtworkAcquisitionController.swift
//  kulon
//
//  Created by Артмеий Шлесберг on 27/03/2018.
//  Copyright © 2018 Jufy. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import  RxCocoa

class ArtworkAcquisitionController: UIViewController {
    
    private var acquisition: Acquisition
    
    private var acquisitionView: ArtworkAcquisitionView
    private var topButton = RoundedButton()
    .with(image: #imageLiteral(resourceName: "icon_top_cancel"))
    .with(tintColor: UIColor.Kulon.orange)
    
    private var disposeBag = DisposeBag()
    
    init(acquisition: Acquisition, artwork: MarketableArtwork) {
        self.acquisition = acquisition
        self.acquisitionView = ArtworkAcquisitionView(acquisition: acquisition)
        super.init(nibName: nil, bundle: nil)
        let topBG = TopBarBackgroundView()
        topBG.backgroundColor = .clear
        self.view.addSubviews([acquisitionView, topBG, topButton])
        acquisitionView.snp.makeConstraints {
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
            self.dismiss(animated: true)
        }).disposed(by: disposeBag)
        
        acquisitionView.wantsToPurchase
            .subscribe(onNext: {
                artwork.purchaseSubject.on(.next())
                self.dismiss(animated: true)
        }).disposed(by: disposeBag)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ArtworkAcquisitionView: UIView {
    
    private var artworkImage = KulonImageView()
        .with(roundedEdges: 21)
        .with(contentMode: .scaleAspectFill)
        .with(backgroundColor: UIColor.Kulon.lightOrange)
    private var artistImage = UIImageView()
        .with(roundedEdges: 16)
        .with(contentMode: .scaleAspectFill)
        .with(backgroundColor: UIColor.Kulon.lightOrange)
    private var artistName = StandardLabel(font: .boldSystemFont(ofSize: 24))
    private var artworkName = StandardLabel(font: .boldSystemFont(ofSize: 24))
    private var price = StandardLabel(font: .boldSystemFont(ofSize: 18))
    private var buyButton = UIButton()
        .with(roundedEdges: 8)
    
    private var disposeBag = DisposeBag()
    
    var wantsToPurchase: Observable<Void> {
        return purchaseSubject
    }
    var wantsToShowError: Observable<Error> {
        return errorSubject
    }
    
    private let recoverSubject = PublishSubject<Void>()
    private let errorSubject = PublishSubject<Error>()
    private let purchaseSubject = PublishSubject<Void>()
    
    init(acquisition: Acquisition) {
    
        Recoverable(origin: buyButton.rx.tap.flatMap { acquisition.purchase() },
                                              recoveringOn: recoverSubject,
                                              reportingErrorsTo: errorSubject
            ).debug()
            .bind(to: purchaseSubject).disposed(by: disposeBag)
        
        buyButton.rx.tap.asObservable()
            .withLatestFrom(errorSubject)
            .debug()
            .map { _ in}
            .bind(to: recoverSubject)
            .disposed(by: disposeBag)
        
        
        super.init(frame: .zero)
        backgroundColor = .white
        
        artistImage.tintColor = .black
        
        artworkName.text = acquisition.purchasable.name
        artistName.text = acquisition.seller.name
        acquisition.seller.avatar.asObservable().bind(to: artistImage.rx.image).disposed(by: disposeBag)
        acquisition.purchasable.image.asObservable().bind(to: artworkImage.rx.image).disposed(by: disposeBag)
        price.text = "\(acquisition.price) POSH"
        
        let sellsLabel = StandardLabel(font: .systemFont(ofSize: 16), textColor: .black, text: "sells yoy:")
        let forLabel = StandardLabel(font: .systemFont(ofSize: 16), textColor: .black, text: "for:")
        [artistImage, artworkImage, artistName, artworkName, price, buyButton, sellsLabel, forLabel]
            .forEach { [unowned self] in self.addSubview($0) }
        
        ([artistName, artworkName, price, sellsLabel, forLabel] as [UIView])
            .forEach {
                $0.snp.makeConstraints {
                    $0.leading.equalToSuperview().offset(88)
                    $0.trailing.equalToSuperview().inset(32)
                }
            }
        artistName.setBelow(view: sellsLabel, offset: 20)
        sellsLabel.setBelow(view: artworkName, offset: 20)
        artworkName.setBelow(view: forLabel, offset: 10)
        forLabel.setBelow(view: price, offset: 19)
        
        artistImage.snp.makeConstraints {
            $0.top.equalToSuperview().offset(112)
        }
        
        buyButton.snp.makeConstraints {
            $0.height.equalTo(36)
            $0.width.equalTo(268)
            $0.bottom.equalToSuperview().inset(60)
            $0.centerX.equalToSuperview()
        }
        buyButton.setTitle("Purchase", for: .normal)
        buyButton.setTitleColor(.black, for: .normal)
        buyButton.backgroundColor = UIColor.Kulon.lightOrange
        
        artistImage.snp.makeConstraints {
            $0.centerY.equalTo(artistName)
            $0.centerX.equalTo(artworkImage)
            $0.height.width.equalTo(32)
        }
        
        artworkImage.snp.makeConstraints {
            $0.height.width.equalTo(42)
            $0.leading.equalToSuperview().offset(34)
            $0.centerY.equalTo(artworkName)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
