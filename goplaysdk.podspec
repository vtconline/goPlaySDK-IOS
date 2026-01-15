Pod::Spec.new do |s|
  s.name             = 'goplaysdk'
  s.version          = '1.0.22'
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
    :tag => 'v1.0.22'
  }


  s.platform         = :ios, '15.0'
  s.ios.deployment_target = '15.0'
  s.swift_version    = '5.9'
  s.static_framework = true   # 👈 BẮT BUỘC để add firebase
  s.pod_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
    'IPHONEOS_DEPLOYMENT_TARGET' => '15.0'

    # 'MACH_O_TYPE' => 'mh_dylib'
  }
  # s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
   s.user_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
    'IPHONEOS_DEPLOYMENT_TARGET' => '15.0'
  }


  s.source_files     = 'Sources/goplaysdk/**/*.swift'
  s.resources        = ['Sources/goplaysdk/images/**/*']
  # s.resource_bundles = {
  # 'goplaysdk' => ['Sources/goplaysdk/images/**/*']
  # }

 

  s.frameworks = [
    'UIKit',
    'SwiftUI',
    'AuthenticationServices'
  ]

  # Dependencies pod search GoogleSignIn --simple. ==> find latest version in cdn, in web cocoapod may not correct with podspec publish
  # s.dependency 'GoogleSignInCommunity', '~> 9.0'
  # s.dependency 'GoogleSignInSwiftSupport', '~> 9.1'
  s.dependency 'VTC-GoogleSignIn', '~> 9.1'
  s.dependency 'FBSDKLoginKit', '~> 18.0'
  s.dependency 'FBSDKCoreKit',  '~> 18.0'
  # s.dependency 'Firebase/Analytics', '~> 12.7'
    s.dependency 'VTC-FirebaseAnalytics', '~> 12.8.0'
  # s.dependency 'Firebase/Crashlytics', '~> 12.7'
  s.dependency 'VTC-SwiftJWT', '4.0.1'

end
