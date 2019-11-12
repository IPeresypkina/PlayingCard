//
//  ViewController.swift
//  PlayingCard
//
//  Created by Ирина Пересыпкина on 17/09/2019.
//  Copyright © 2019 Ирина Пересыпкина. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var deck = PlayingCardDeck()
    @IBOutlet weak var playingCardView: PlayingCardView! {
        didSet {
            // ​#selector ​- это просто любая функция
            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(nextCard))
            swipe.direction = [.left,.right]
            playingCardView.addGestureRecognizer(swipe)
            let pinch = UIPinchGestureRecognizer(target: playingCardView, action: #selector(playingCardView.adjustFaceCardScale(byHandlingGestureBy:)))
            playingCardView.addGestureRecognizer(pinch)
        }
    }
    
    @IBAction func flipCard(_ sender: UITapGestureRecognizer) {
        /*switch sender.state {
        case .ended: playingCardView.isFaceup = !playingCardView.isFaceup
        default: break
        }*/
    playingCardView.isFaceup = !playingCardView.isFaceup
    }
    //обеспечит переход к следующей карте вызывается когда происходит жест swipe
    @objc func nextCard() {
        if let card = deck.draw() {
            playingCardView.rank = card.rank.order
            playingCardView.suit = card.suit.rawValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*for _ in 1...10 {
            //мы поставили if let потому что card это ​Optional<PlayingCard> !!!!!!!!!!!!!!!
            if let card = deck.draw() {
                print("\(card)")
            }
        }*/
    }
}

