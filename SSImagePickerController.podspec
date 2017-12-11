#
#  Be sure to run `pod spec lint SSImagePickerViewController.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name         = "SSImagePickerController"
  s.version      = "0.1.0"
  s.summary      = "A simple Image picker controller"
  s.homepage     = "https://github.com/xtcel/SSImagePickerController"
  s.license      = "MIT"
  s.author       = { "xtcel" => "xtcelme@163.com" }
  s.platform     = :ios
  s.ios.deployment_target = "6.0"
  s.source       = { :git => "https://github.com/xtcel/SSImagePickerController.git", :tag => "0.1.0" }
  s.requires_arc = true
  s.resources    = "SSImagePickerController/SSImagePickerController/*.{png,bundle}"
  s.source_files = "SSImagePickerController/SSImagePickerController/*.{h,m}"
  s.frameworks   = "Photos","AssetsLibrary"
  s.dependency "Masonry", "~> 1.1.0"
end
