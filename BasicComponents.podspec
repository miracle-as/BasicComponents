Pod::Spec.new do |s|
  s.name         = 'BasicComponents'
  s.version      = '3.0.0'
  s.summary      = 'BasicComponents includes Miracle A/S commonly used base components for iOS projects.'

  s.homepage     = 'https://github.com/miracle-as/BasicComponents'

  s.license      = { :type => 'MIT', :file => 'LICENSE' }

  s.author             = { 'Lasse Løvdahl' => 'llo@miracle.dk' }
# s.social_media_url   = 'http://twitter.com/Lasse Løvdahl'

  s.ios.deployment_target = '9.0'

  s.source       = { :git => 'https://github.com/miracle-as/BasicComponents.git', :tag => s.version }

  s.source_files = 'BasicComponents/*.swift'

  s.framework    = 'UIKit'
  s.frameworks   = 'Foundation'
  s.frameworks   = 'AVFoundation'

  s.requires_arc = true

  s.dependency 'Sugar'
  s.dependency 'DynamicColor'
  s.dependency 'Whisper'

  # s.resources = 'BasicComponents/**/*.{png,jpeg,jpg,storyboard,xib}'
end
