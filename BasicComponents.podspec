Pod::Spec.new do |s|
  s.name         = 'BasicComponents'
  s.version      = '2.3.0'
  s.summary      = 'BasicComponents includes Miracle A/S commonly used base components for iOS projects.'

  s.homepage     = 'https://github.com/miracle-as/BasicComponents'

  s.license      = { :type => 'MIT', :file => 'LICENSE' }

  s.author             = { 'Lasse Løvdahl' => 'llo@miracle.dk' }
# s.social_media_url   = 'http://twitter.com/Lasse Løvdahl'

  s.ios.deployment_target = '8.0'

  s.source       = { :git => 'https://github.com/miracle-as/BasicComponents', :tag => s.version }

  s.source_files = 'BasicComponents/*.swift'

  s.framework    = 'UIKit'
  s.frameworks   = 'Foundation'
  s.frameworks   = 'AVFoundation'

  s.requires_arc = true

  s.dependency 'Sugar', '~> 1.0', :git => 'https://github.com/pherret/Sugar', :branch => 'swift2.3'
  s.dependency 'DynamicColor', '~> 2.0'
  s.dependency 'Whisper', '~> 3.0'

  # s.resources = 'BasicComponents/**/*.{png,jpeg,jpg,storyboard,xib}'
end
