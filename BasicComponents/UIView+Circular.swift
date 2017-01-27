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

  public var contentView: UIView? {
    get {
      return subviews.first
    }

    set {
      guard
        let view = newValue,
        !subviews.contains(view) else {
          return
      }

      let viewsToRemove = subviews

      view.translatesAutoresizingMaskIntoConstraints = false
      addSubview(view)

      NSLayoutConstraint.activate([
        view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
        view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
        view.topAnchor.constraint(equalTo: topAnchor, constant: 0),
        view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
        ])

      if let fromView = viewsToRemove.first {
        UIView.transition(from: fromView,
                          to: view,
                          duration: 0.5,
                          options: .transitionCrossDissolve) { done in
                            viewsToRemove.forEach { $0.removeFromSuperview() }
        }
      }
    }
  }
}
