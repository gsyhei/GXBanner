#
#  Be sure to run `pod spec lint GXBanner.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "GXBanner"
  s.version      = "1.0.2"
  s.summary      = "一款简单又好用的广告banner."
  s.homepage     = "https://github.com/gsyhei/GXBanner"
  s.license      = "MIT"
  s.author       = { "Gin" => "279694479@qq.com" }
  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/gsyhei/GXBanner.git", :tag => "1.0.2" }
  s.requires_arc = true
  s.source_files = "GXBanner"
  s.frameworks   = "Foundation","UIKit"

end
