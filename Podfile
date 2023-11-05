## Uncomment the next line to define a global platform for your project
platform :ios, '14.1'

source 'https://github.com/turnercode/prism-pod-specs.git'
source 'https://github.com/CocoaPods/Specs.git'

install! 'cocoapods', :generate_multiple_pod_projects => false, :incremental_installation => false

target 'WarnerMedia Privacy Test App' do
  # Comment the next line if you don't want to use dynamic frameworks
  # use_frameworks!
  use_modular_headers!

  # Pods for WarnerMedia Privacy Test App
  # pod 'OneTrust-CMP-XCFramework'
  pod 'Google-Mobile-Ads-SDK'
  pod 'FBSDKCoreKit'
  pod 'Analytics'
  pod 'Segment-Firebase'
  pod 'mopub-ios-sdk'
  # pod 'AmazonAd'
  pod 'PrismiOS'
  pod 'AppLovinSDK'
  # pod 'OneTrust-CMP-XCFramework', '~> 6.18.0.0'
  # pod "VungleSDK-iOS"
  # pod 'FBAudienceNetwork'
  # pod 'FacebookCore'
  # pod 'Firebase/Analytics'
  # pod 'React'

  target 'WarnerMedia Privacy Test AppTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'WarnerMedia Privacy Test AppUITests' do
    # Pods for testing
  end

  post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
    end
  end
 end
end
