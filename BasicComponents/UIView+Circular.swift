//
//  CircularButton.swift
//  Grunddata
//
//  Created by Lasse Løvdahl on 03/11/2015.
//  Copyright © 2015 Miracle A/S. All rights reserved.
//

import UIKit

public extension UIView {
	@IBInspectable public var cornerRadius: CGFloat {
		get {
			return layer.cornerRadius
		}
		set {
			layer.cornerRadius = newValue
			layer.masksToBounds = newValue > 0
		}
	}
  @IBInspectable public var border: CGFloat {
    get {
      return layer.borderWidth
    }
    set {
      layer.borderWidth = newValue
    }
  }
  @IBInspectable public var borderColor: UIColor? {
    get {
      if let color = layer.borderColor {
        return UIColor(cgColor: color)
      }
      return .none
    }
    set {
      layer.borderColor = newValue != .none ? newValue!.cgColor : .none
    }
  }
}
