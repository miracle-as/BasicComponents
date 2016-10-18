//
//  VideoInBackgroundView.swift
//  UniMinds
//
//  Created by Lasse Løvdahl on 22/04/2016.
//  Copyright © 2016 UniMinds. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

open class VideoInBackgroundView: UIView {

  fileprivate var playerDidPlayToTheEndNotificationToken: AnyObject?

  lazy var player: AVPlayer = {
    if let path = Bundle.main.path(forResource: self.videoName, ofType: "mp4") {

      let item = AVPlayerItem(url: URL(fileURLWithPath: path))

      let player = AVPlayer(playerItem: item)
      player.actionAtItemEnd = .none

      self.playerDidPlayToTheEndNotificationToken = NotificationCenter.default
        .addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: item, queue: .none) { _ in
          player.seek(to: kCMTimeZero)
      }

      return player
    } else {
      return AVPlayer()
    }
  }()

  lazy var playerLayer: AVPlayerLayer = AVPlayerLayer(player: self.player)

  @IBInspectable
  open var videoName: String! {
    willSet {
      if videoName != .none {
        fatalError("Video in background player cannot be changed")
      }
    }

    didSet {
      if videoName != .none {
        layer.addSublayer(playerLayer)
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill

        player.play()
      }
    }
  }


  override open func layoutSubviews() {
    super.layoutSubviews()

    playerLayer.frame = bounds
  }


  deinit {
    if let playerDidPlayToTheEndNotificationToken = playerDidPlayToTheEndNotificationToken {
      NotificationCenter.default.removeObserver(playerDidPlayToTheEndNotificationToken)
    }
  }
  
}
