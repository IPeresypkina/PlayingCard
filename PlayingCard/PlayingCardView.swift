//
//  PlayingCardView.swift
//  PlayingCard
//
//  Created by Ирина Пересыпкина on 18/09/2019.
//  Copyright © 2019 Ирина Пересыпкина. All rights reserved.
//

import UIKit

@IBDesignable
class PlayingCardView: UIView {
    @IBInspectable
    var rank: Int = 12 {didSet {setNeedsDisplay(); setNeedsLayout()} }
    @IBInspectable
    var suit: String = "♥️" {didSet {setNeedsDisplay(); setNeedsLayout()} }
    @IBInspectable
    var isFaceup: Bool = true {didSet {setNeedsDisplay(); setNeedsLayout()} }
    //масштаб изображения
    var faceCardScale: CGFloat = SizeRatio.faceCardImageSizeToBoundsSize {
        didSet {
            setNeedsDisplay()
        }
    }
    
    
    
    @objc func adjustFaceCardScale(byHandlingGestureBy recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case.changed,.ended:
            faceCardScale *= recognizer.scale
            recognizer.scale = 1.0
        default: break
        }
    }
    
    override func draw(_ rect: CGRect) {
        //для создания прямоугольника с закругленными углами
        let roundedRect = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        roundedRect.addClip()
        UIColor.white.setFill()
        roundedRect.fill()
        //Если нам удалось найти изображение ​faceCardImage​ в файле ​Assets.xcassets​, то мы рисуем его внутри границ ​bounds​ нашего ​view
        if isFaceup {
            if let faceCardImage = UIImage(named: rankStringID+suit, in: Bundle(for: self.classForCoder), compatibleWith: traitCollection) {
                faceCardImage.draw(in: bounds.zoom(by:faceCardScale))
            } else {
                drawPips()
            }
        } else {
            if let cardBackImage = UIImage(named: "cardback", in: Bundle(for: self.classForCoder), compatibleWith: traitCollection){
                cardBackImage.draw(in: bounds)
            }
        }
    }
    
    private func centeredAttributedString(_ string: String, fontSize: CGFloat) -> NSAttributedString {
        //если в настройках кто то поменяет размер шрифта то благодаря этим двум строчкам кода в нашем приложении тоже поменяется шрифт автоматически
        var font = UIFont.preferredFont(forTextStyle: .body).withSize(fontSize)
        font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
        //центрирование
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        return  NSAttributedString(string: string, attributes: [.paragraphStyle: paragraphStyle,.font:font])
    }
    
    private var cornerString: NSAttributedString {
        return centeredAttributedString(rankStringID + "\n" + suit, fontSize: cornerFontSize)
    }
    
    //метка левого верхнего угла
    private lazy var upperLeftCornerLabel = createCornerLabel()
    //метка правого нижнего угла
    private lazy var lowerRightCornerLabel = createCornerLabel()
    
    private func createCornerLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        addSubview(label)
        return label
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //Правый верхний угол
        configureCornerLabel(upperLeftCornerLabel)
        upperLeftCornerLabel.frame.origin = bounds.origin.offsetBy(dx: cornerOffset, dy: cornerOffset)
        //Левый нижний угол
        configureCornerLabel(lowerRightCornerLabel)
        //На​ 𝞹 ​радиан, потому что я должен пройти половину окружности, чтобы оказаться “вверх ногами”
        //сначала аперемещаем потом вращаем
        lowerRightCornerLabel.transform = CGAffineTransform.identity.translatedBy(x: lowerRightCornerLabel.frame.size.width, y: lowerRightCornerLabel.frame.size.height).rotated(by: CGFloat.pi)
        lowerRightCornerLabel.frame.origin = CGPoint(x: bounds.maxX, y: bounds.maxY).offsetBy(dx: -cornerOffset, dy: -cornerOffset).offsetBy(dx: -lowerRightCornerLabel.frame.size.width, dy: -lowerRightCornerLabel.frame.size.height)
        
    }
    
    //Одна вещь, которая мне необходима, это установка текста с атрибутами для строки
    private func configureCornerLabel(_ label: UILabel) {
        label.attributedText = cornerString
        //подгоняет” размер метки к ее содержимому
        label.frame.size = CGSize.zero
        label.sizeToFit()
        //Вместо того, чтобы рисовать “обратную” сторону игральной карты, мы просто скрыли угловые метки.
        label.isHidden = !isFaceup
    }
    //для изменения размера шрифта автоматически
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setNeedsDisplay()
        setNeedsLayout()
    }
    
    //рисуем pips
    private func drawPips()
    {
        let pipsPerRowForRank = [[0], [1], [1,1], [1,1,1], [2,2], [2,1,2], [2,2,2], [2,1,2,2], [2,2,2,2], [2,2,1,2,2], [2,2,2,2,2]]
        
        func createPipString(thatFits pipRect: CGRect) -> NSAttributedString {
            let maxVerticalPipCount = CGFloat(pipsPerRowForRank.reduce(0) { max($1.count, $0)})
            let maxHorizontalPipCount = CGFloat(pipsPerRowForRank.reduce(0) { max($1.max() ?? 0, $0)})
            let verticalPipRowSpacing = pipRect.size.height / maxVerticalPipCount
            let attemptedPipString = centeredAttributedString(suit, fontSize: verticalPipRowSpacing)
            let probablyOkayPipStringFontSize = verticalPipRowSpacing / (attemptedPipString.size().height / verticalPipRowSpacing)
            let probablyOkayPipString = centeredAttributedString(suit, fontSize: probablyOkayPipStringFontSize)
            if probablyOkayPipString.size().width > pipRect.size.width / maxHorizontalPipCount {
                return centeredAttributedString(suit, fontSize: probablyOkayPipStringFontSize /
                    (probablyOkayPipString.size().width / (pipRect.size.width / maxHorizontalPipCount)))
            } else {
                return probablyOkayPipString
            }
        }
        if pipsPerRowForRank.indices.contains(rank) {
            let pipsPerRow = pipsPerRowForRank[rank]
            var pipRect = bounds.insetBy(dx: cornerOffset, dy: cornerOffset).insetBy(dx: cornerString.size().width, dy: cornerString.size().height / 2)
            let pipString = createPipString(thatFits: pipRect)
            let pipRowSpacing = pipRect.size.height / CGFloat(pipsPerRow.count)
            pipRect.size.height = pipString.size().height
            pipRect.origin.y += (pipRowSpacing - pipRect.size.height) / 2
            for pipCount in pipsPerRow {
                switch pipCount {
                case 1:
                    pipString.draw(in: pipRect)
                case 2:
                    pipString.draw(in: pipRect.leftHalf)
                    pipString.draw(in: pipRect.rightHalf)
                default:
                    break
                }
                pipRect.origin.y += pipRowSpacing
            }
        }
    }
    
    
}

//расширения:
extension PlayingCardView {
    //В этой структуре находится:
    private struct SizeRatio {
        //размер шрифта для метки в углу карты по отношению к высоте карты
        static let cornerFontSizeToBoundsHeight: CGFloat = 0.085
        //радиус угла карты по отношению к высоте карты
        static let cornerRadiusToBoundsHeight: CGFloat = 0.06
        //смещение угла по отношению к радиусу угла карты
        static let cornerOffsetToCornerRadius: CGFloat = 0.33
        //также есть размер изображения “картинки” для карт с “картинкой” по отношению к размеру карты
        static let faceCardImageSizeToBoundsSize: CGFloat = 0.75
    }
    //вычисляемые свойства
    private var cornerRadius: CGFloat {
        //берет высоту карты и умножает на соотношение ​cornerRadiusToBoundsHeight​:
        return bounds.size.height * SizeRatio.cornerRadiusToBoundsHeight
    }
    
    private var cornerOffset: CGFloat {
        return cornerRadius * SizeRatio.cornerOffsetToCornerRadius
    }
    
    private var cornerFontSize: CGFloat {
        return bounds.size.height * SizeRatio.cornerFontSizeToBoundsHeight
    }
    //вычисляемая переменная оторая преобразует ранг карты ​в строку а все другие числа в строку String(rank)
    private var rankStringID: String {
        switch rank {
        case 1: return "A"
        case 2...10: return String(rank)
        case 11: return "J"
        case 12: return "Q"
        case 13: return "K"
        default: return "?"
        }
    }
}

extension CGRect {
    var leftHalf: CGRect {
        return CGRect(x: minX, y: minY, width: width/2, height: height)
    }
    var rightHalf: CGRect {
        return CGRect(x: midX, y: minY, width: width/2, height: height)
    }
    func inset(by size: CGSize) -> CGRect {
        return insetBy(dx: size.width, dy: size.height)
    }
    func sized(to size: CGSize) -> CGRect {
        return CGRect(origin: origin, size: size)
    }
    func zoom(by scale: CGFloat) -> CGRect {
        let newWidth = width * scale
        let newHeight = height * scale
        return insetBy(dx: (width - newWidth) / 2, dy: (height - newHeight) / 2)
    }
}

//Смещение ​offsetBy​ задается в расширении ​extention​ для ​CGPoint​ и перемещает точку на некоторое расстояние, задаваемое координатами ​dx​, ​dy
extension CGPoint {
    func offsetBy(dx: CGFloat, dy: CGFloat) -> CGPoint {
        return CGPoint(x: x+dx, y: y+dy)
    }
}

