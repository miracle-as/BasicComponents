//
//  GradientView.swift
//  Danland
//
//  Created by Morten Fast on 09/05/16.
//  Copyright © 2016 Dancenter. All rights reserved.
//

import UIKit

open class VerticalGradientView: UIView {

  var gradientLayer: CAGradientLayer {
    return layer as! CAGradientLayer
  }

  @IBInspectable
  open var topColor: UIColor? {
    didSet {
      setColors()
    }
  }

  @IBInspectable
  open var bottomColor: UIColor? {
    didSet {
      setColors()
    }
  }

  func setColors() {
    gradientLayer.colors = [topColor ?? .white, bottomColor ?? .black].map { $0.cgColor }
    backgroundColor = .clear
  }

  @IBInspectable
  open var position: Double = 0 {
    didSet {
      gradientLayer.startPoint = CGPoint(x: 0.5, y: position)
    }
  }

  override open class var layerClass : AnyClass {
    return CAGradientLayer.self
  }
}
