Pod::Spec.new do |s|
  s.name         = 'BasicComponents'
  s.version      = '0.2.3'
  s.summary      = 'BasicComponents includes Miracle A/S commonly used base components for iOS projects.'

  s.homepage     = 'https://bitbucket.org/loevdahl/basiccomponents/overview'

  s.license      = { :type => 'MIT', :file => 'LICENSE' }

  s.author             = { 'Lasse Løvdahl' => 'llo@miracle.dk' }
# s.social_media_url   = 'http://twitter.com/Lasse Løvdahl'

  s.ios.deployment_target = '8.0'

  s.source       = { :git => 'https://loevdahl@bitbucket.org/loevdahl/basiccomponents.git', :tag => s.version }

  s.source_files = 'BasicComponents/*.swift'

  s.framework    = 'UIKit'
  s.frameworks   = 'Foundation'
  s.frameworks   = 'AVFoundation'

  s.requires_arc = true

  s.dependency 'Sugar', '~> 1.0'
  s.dependency 'DynamicColor', '~> 2.0'
  s.dependency 'Whisper', '~> 2.0'

  # s.resources = 'BasicComponents/**/*.{png,jpeg,jpg,storyboard,xib}'
end