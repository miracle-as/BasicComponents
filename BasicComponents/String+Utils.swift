//
//  Utils.swift
//  Ejendomspriser
//
//  Created by Lasse Løvdahl on 13/01/2016.
//  Copyright © 2016 Miracle A/S. All rights reserved.
//

import Foundation
import DynamicColor
//import UIKit

extension String {

  public func removeLeadingZeros() -> String {
    return characters.reduce("") { result, character in
      if !(result.isEmpty && character == "0") {
        return result + "\(character)"
      }
      return result
      }
      .stringByTrimmingCharactersInSet(.whitespaceAndNewlineCharacterSet())
  }


  public var color: UIColor {
    let hexString = stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    let scanner   = NSScanner(string: hexString)

    if (hexString.hasPrefix("#")) {
      scanner.scanLocation = 1
    }

    var color: UInt32 = 0
    if scanner.scanHexInt(&color) {
      return initColor(color)
    }
    else {
      return initColor(0x000000)
    }
  }

  /**
   Creates a color from an hex integer.

   - parameter hex: A hexa-decimal UInt32 that represents a color.
   */
  private func initColor (hex: UInt32) -> UIColor {
    let mask = 0x000000FF

    let r = Int(hex >> 16) & mask
    let g = Int(hex >> 8) & mask
    let b = Int(hex) & mask

    let red   = CGFloat(r) / 255
    let green = CGFloat(g) / 255
    let blue  = CGFloat(b) / 255

    return UIColor(red:red, green:green, blue:blue, alpha:1)
  }
}
