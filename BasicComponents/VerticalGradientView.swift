//
//  GradientView.swift
//  Danland
//
//  Created by Morten Fast on 09/05/16.
//  Copyright © 2016 Dancenter. All rights reserved.
//

import UIKit

@IBDesignable
public class VerticalGradientView: UIView {

  var gradientLayer: CAGradientLayer {
    return layer as! CAGradientLayer
  }

  @IBInspectable
  public var topColor: UIColor? {
    didSet {
      setColors()
    }
  }

  @IBInspectable
  public var bottomColor: UIColor? {
    didSet {
      setColors()
    }
  }

  func setColors() {
    gradientLayer.colors = [topColor ?? .whiteColor(), bottomColor ?? .blackColor()].map { $0.CGColor }
  }

  @IBInspectable
  public var position: Double = 0 {
    didSet {
      gradientLayer.startPoint = CGPoint(x: 0.5, y: position)
    }
  }

  override public class func layerClass() -> AnyClass {
    return CAGradientLayer.self
  }
}
