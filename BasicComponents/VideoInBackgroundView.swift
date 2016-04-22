//
//  VideoInBackgroundView.swift
//  UniMinds
//
//  Created by Lasse Løvdahl on 22/04/2016.
//  Copyright © 2016 UniMinds. All rights reserved.
//

import Foundation
import UIKit
//import AVKit
import AVFoundation

public class VideoInBackgroundView: UIView {

  private var playerDidPlayToTheEndNotificationToken: AnyObject?

  lazy var player: AVPlayer = {
    let path = NSBundle.mainBundle().pathForResource(self.videoName, ofType: "mp4")!
    let item = AVPlayerItem(URL: NSURL(fileURLWithPath: path))

    let player = AVPlayer(playerItem: item)
    player.actionAtItemEnd = .None

    self.playerDidPlayToTheEndNotificationToken = NSNotificationCenter.defaultCenter()
      .addObserverForName(AVPlayerItemDidPlayToEndTimeNotification, object: item, queue: .None) { _ in
      player.seekToTime(kCMTimeZero)
    }

    return player
  }()

  lazy var playerLayer: AVPlayerLayer = AVPlayerLayer(player: self.player)

  @IBInspectable
  public var videoName: String! {
    willSet {
      if videoName != .None {
        fatalError("Video in background player cannot be changed")
      }
    }

    didSet {
      if videoName != .None {
        layer.addSublayer(playerLayer)
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill

        player.play()
      }
    }
  }


  override public func layoutSubviews() {
    super.layoutSubviews()

    playerLayer.frame = bounds
  }


  deinit {
    if let playerDidPlayToTheEndNotificationToken = playerDidPlayToTheEndNotificationToken {
      NSNotificationCenter.defaultCenter().removeObserver(playerDidPlayToTheEndNotificationToken)
    }
  }

}
