//
//  CircularButton.swift
//  Grunddata
//
//  Created by Lasse Løvdahl on 03/11/2015.
//  Copyright © 2015 Miracle A/S. All rights reserved.
//

import UIKit

@IBDesignable
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
}
