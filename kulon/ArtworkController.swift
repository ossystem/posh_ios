//
// Created by Артмеий Шлесберг on 23/03/2018.
// Copyright (c) 2018 Jufy. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import SnapKit

class ArtworkController: UIViewController {

    private var artwork: MarketableArtwork
    private var infoView = ArtworkInfoView()

    private var disposeBag = DisposeBag()

    init(with artwork: MarketableArtwork) {
        self.artwork = artwork
        super.init(nibName: nil, bundle: nil)
        view.addSubview(infoView)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        artwork.info.subscribe(onNext: { [unowned self] in
            self.infoView.setup(with: $0)
        }).disposed(by: disposeBag)
    }
}

class ArtworkInfoView: UIView {

    private var artworkImage = UIImageView()
    private var artistImage = UIImageView()
    private var artistName = UILabel()
    private var artworkName = UILabel()
    private var price = UILabel()
    private var buyButton = UIButton()
    private var likeButton = UIButton()

    init() {
        super.init(frame: .zero)
        [artistImage, artistImage, artistName, artworkName, price, buyButton, likeButton]
                .forEach { [unowned self] in self.addSubview($0) }
        [artistImage, artistImage, artistName, artworkName, price, buyButton]
                .forEach(<#T##body: (UIImageView) throws -> Void##(UIKit.UIImageView) throws -> Swift.Void#>)

    }
    func setup(with info: ArtworkInfo) {

    }
}