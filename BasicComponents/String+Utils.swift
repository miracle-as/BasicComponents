//
//  Utils.swift
//  Ejendomspriser
//
//  Created by Lasse Løvdahl on 13/01/2016.
//  Copyright © 2016 Miracle A/S. All rights reserved.
//

import Foundation
import DynamicColor

extension String {

  public func removeLeadingZeros() -> String {
    return characters.reduce("") { result, character in
      if !(result.isEmpty && character == "0") {
        return result + "\(character)"
      }
      return result
      }
      .trimmingCharacters(in: .whitespacesAndNewlines())
  }

  
  public var color: UIColor {
    return UIColor(hexString: self)
  }
}
