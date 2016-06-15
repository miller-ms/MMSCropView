#
# Be sure to run `pod lib lint MMSCropView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "MMSCropView"
  s.version          = "1.0.0"
  s.summary          = "A view controller supporting the feature to crop an image."

s.description      = <<-DESC
This class supports the feature for dragging a rectangle over a UIImageView and returning a UIImage with the pixels beneath the crop rectangle cropped from the underlying image.
DESC

  s.homepage         = "https://github.com/miller-ms/MMSCropView"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "William Miller" => "support@millermobilesoft.com" }
  s.source           = { :git => "https://github.com/<GITHUB_USERNAME>/MMSCropView.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'MMSCropView' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
