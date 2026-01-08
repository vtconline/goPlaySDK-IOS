Pod::Spec.new do |s|
  s.name             = 'goplaysdk'
  s.version          = '1.0.15'
  s.summary          = 'GoPlay SDK for iOS'

  s.description      = <<-DESC
GoPlaySDK provides login and authentication features:
- Apple Login
- Google Sign-In
- Facebook Login
- Firebase Analytics & Crashlytics
- Guest / GoID login
Written in Swift & SwiftUI.
  DESC

  s.homepage         = 'https://vtconline.vn'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'vtconline' => 'domain@go.vn' }

  s.source           = {
    :git => 'https://github.com/vtconline/goPlaySDK-IOS.git',
    :tag => 'v1.0.15'
  }

  s.platform         = :ios, '15.0'
  s.swift_version    = '5.9'
  s.static_framework = true


  s.source_files     = 'Sources/goplaysdk/**/*.swift'
  s.resources        = ['Sources/goplaysdk/images/**/*']

  s.frameworks = [
    'UIKit',
    'SwiftUI',
    'AuthenticationServices'
  ]

  # Dependencies
  s.dependency 'GoogleSignIn', '~> 9.0'
  s.dependency 'FBSDKLoginKit', '~> 16.0'
  s.dependency 'FBSDKCoreKit',  '~> 16.0'
  s.dependency 'Firebase/Analytics', '12.7.0'
  s.dependency 'Firebase/Crashlytics', '12.7.0'
  s.dependency 'SwiftJWT', '3.6.200'
end
