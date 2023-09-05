# frozen_string_literal: true

# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

source 'https://github.com/CocoaPods/Specs.git'
#source 'https://cdn.cocoapods.org/'

inhibit_all_warnings!
#use_frameworks!

def common_pods
  pod 'YCBase'
  pod 'YCEasyTool'
  pod 'SAMKeychain'
  pod 'OpenSSL-Universal', '1.1.1500'
  pod 'CocoaLumberjack'
  pod 'SocketRocket'
  pod 'Reachability', '~> 3.2'
  pod 'MJExtension', '~>3.0.13'
  pod 'FileMD5Hash'
  pod 'AFNetworking', '~> 4.0'
  pod 'JSONModel', '~> 1.2'
  pod 'ISO8601', '~> 0.6'
end

target 'EulixSpace' do
  common_pods

  pod 'SDWebImage', '5.12.5'
  pod 'YYModel'
  pod 'YYCache'
  pod 'FLAnimatedImage', '~> 1.0'
  pod 'Masonry'
  pod 'WCDB'
  pod 'SVProgressHUD'
  pod 'SDCycleScrollView', '>= 1.82'
  pod 'IQKeyboardManager'
  pod 'SSZipArchive', '2.2.3'
  pod 'GKPhotoBrowser', '2.4.1'
  pod "GCDWebServer", "~> 3.0"
  pod 'lottie-ios'
end

target 'EulixSpaceTests' do
  common_pods
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
      config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
    end
  end
end
