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

public func statusBarNotify(message: String, color: UIColor = .clearColor()) {
  let murmur = Murmur(title: message, backgroundColor: color, titleColor: color.isLightColor() ? .blackColor() : .whiteColor())
  show(whistle: murmur, action: .Show(2))
}


public extension UIViewController {

  public func askUserFor(title: String, message: String, whenAsked: (ok: Bool) -> Void) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)

    let cancelAction = UIAlertAction(title: "Annuller", style: .Cancel) { _ in
      whenAsked(ok: false)
    }
    alertController.addAction(cancelAction)

    let OKAction = UIAlertAction(title: "OK", style: .Default) { _ in
      whenAsked(ok: true)
    }
    alertController.addAction(OKAction)

    self.presentViewController(alertController, animated: true) {
    }
  }


  public func alert(title: String = "Error", message: String, whenAcknowledge: () -> Void) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)

    let OKAction = UIAlertAction(title: "OK", style: .Default) { _ in
      whenAcknowledge()
    }
    alertController.addAction(OKAction)

    self.presentViewController(alertController, animated: true) {
    }
  }


  public func close(animate animated: Bool) {
    if let navigationController = navigationController {
      navigationController.popViewControllerAnimated(animated)
    } else {
      dismissViewControllerAnimated(animated, completion: .None)
    }
  }


  public var isVisible: Bool {
    if isViewLoaded() {
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
      delegate = UIApplication.sharedApplication().delegate,
      window = delegate.window,
      win = window {
      return CGRectEqualToRect(win.frame, win.screen.bounds)
    }
    return true
  }


  class var className: String {
    get {
      return NSStringFromClass(self).componentsSeparatedByString(".").last!
    }
  }


  private class func instanceFromMainStoryboardHelper<T>() -> T? {
    if let
      appDelegate = UIApplication.sharedApplication().delegate,
      rvc = appDelegate.window??.rootViewController,
      controller = rvc.storyboard?.instantiateViewControllerWithIdentifier(className) as? T {
      return controller
    }
    return .None
  }


  public class func instanceFromMainStoryboard() -> Self? {
    return instanceFromMainStoryboardHelper()
  }
}
