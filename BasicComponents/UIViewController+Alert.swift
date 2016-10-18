//
//  UIViewController+Alert.swift
//  Metronome
//
//  Created by Lasse Løvdahl on 05/02/2016.
//  Copyright © 2016 Miracle A/S. All rights reserved.
//

import Foundation
import UIKit
import Whisper
import DynamicColor

public func statusBarNotify(_ message: String, color: UIColor = .clear()) {
  let murmur = Murmur(title: message, backgroundColor: color, titleColor: color.isLightColor() ? .blackColor() : .whiteColor())
  show(whistle: murmur, action: .Show(2))
}


public extension UIViewController {

  public func askUserFor(_ title: String, message: String, whenAsked: @escaping (_ ok: Bool) -> Void) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

    let cancelAction = UIAlertAction(title: "Annuller", style: .cancel) { _ in
      whenAsked(false)
    }
    alertController.addAction(cancelAction)

    let OKAction = UIAlertAction(title: "OK", style: .default) { _ in
      whenAsked(true)
    }
    alertController.addAction(OKAction)

    self.present(alertController, animated: true) {
    }
  }


  public func alert(_ title: String = "Error", message: String, whenAcknowledge: @escaping () -> Void) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

    let OKAction = UIAlertAction(title: "OK", style: .default) { _ in
      whenAcknowledge()
    }
    alertController.addAction(OKAction)

    self.present(alertController, animated: true) {
    }
  }


  public func close(animate animated: Bool) {
    if let navigationController = navigationController {
      navigationController.popViewController(animated: animated)
    } else {
      dismiss(animated: animated, completion: .none)
    }
  }


  public var isVisible: Bool {
    if isViewLoaded {
      return view.window != nil
    }
    return false
  }


  public var contentViewController: UIViewController {
    if let vc = self as? UINavigationController {
      return vc.topViewController ?? self
    } else {
      return self
    }
  }


  public var isTopViewController: Bool {
    if self.navigationController != nil {
      return self.navigationController?.visibleViewController === self
    } else if self.tabBarController != nil {
      return self.tabBarController?.selectedViewController == self && self.presentedViewController == nil
    } else {
      return self.presentedViewController == nil && self.isVisible
    }
  }


  public var isRunningInFullScreen: Bool {
    if let
      delegate = UIApplication.shared.delegate,
      let window = delegate.window,
      let win = window {
      return win.frame.equalTo(win.screen.bounds)
    }
    return true
  }


  class var className: String {
    get {
      return NSStringFromClass(self).components(separatedBy: ".").last!
    }
  }


  fileprivate class func instanceFromMainStoryboardHelper<T>() -> T? {
    if let
      appDelegate = UIApplication.shared.delegate,
      let rvc = appDelegate.window??.rootViewController,
      let controller = rvc.storyboard?.instantiateViewController(withIdentifier: className) as? T {
      return controller
    }
    return .none
  }


  public class func instanceFromMainStoryboard() -> Self? {
    return instanceFromMainStoryboardHelper()
  }
}
