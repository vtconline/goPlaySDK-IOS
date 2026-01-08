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
    # :tag => s.version.to_s
    :tag => "v1.0.15"
  }

  s.platform         = :ios, '15.0'
  s.swift_version    = '5.9'

  s.ios.deployment_target = '12.0'

  # s.pod_target_xcconfig = {
  # 'IPHONEOS_DEPLOYMENT_TARGET' => '15.0'
  # }

  # s.user_target_xcconfig = {
  #   'IPHONEOS_DEPLOYMENT_TARGET' => '15.0'
  # }

  # 📂 Source
  s.source_files     = 'Sources/goplaysdk/**/*.{swift}'

  # 🖼 Resources
  # s.resource_bundles = {
  #   'goplaysdk' => ['Sources/goplaysdk/images/**/*']
  # }
  s.resources    = ['Sources/goplaysdk/images/**/*']


  # 🧩 System Frameworks
  s.frameworks = [
    'UIKit',
    'SwiftUI',
    'AuthenticationServices'
  ]

  # ===== DEPENDENCIES =====  
  # Google Sign-In (từ v7.0.0)  
  s.dependency 'GoogleSignIn', '~> 7.0'    
  # Facebook SDK (chính xác v14.1.0)  
  s.dependency 'FBSDKLoginKit', '14.1.0'  
  s.dependency 'FBSDKCoreKit', '14.1.0'    
  # Firebase (chính xác v12.1.0)  
  s.dependency 'Firebase/Analytics', '12.1.0'  
  s.dependency 'Firebase/Auth', '12.1.0'  
  # Thêm các Firebase modules khác nếu cần: 
  # s.dependency 'Firebase/Firestore', '12.1.0'  
  # s.dependency 'Firebase/Messaging', '12.1.0'    
  # Swift-JWT (từ v4.0.2)  
  s.dependency 'SwiftJWT', '~> 4.0'
end
