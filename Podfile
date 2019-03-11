# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'
use_frameworks!

target 'Router' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # UI
  pod 'Hero'
  pod 'Charts'
  pod 'JGProgressHUD'
  pod 'NewPopMenu', '~> 2.0'
  pod 'NotificationBannerSwift'
  pod 'MarkdownKit'
  
  # Func
  pod 'NMSSH'
  pod 'Alamofire', '~> 4.5'
  pod 'SwiftyJSON'
  pod 'IQKeyboardManagerSwift'
  pod 'PlainPing'
  
  # 百度统计
  pod 'BaiduMobStatCodeless'
  
  post_install do |installer|
      installer.pods_project.targets.each do |target|
          target.build_configurations.each do |config|
              config.build_settings['SWIFT_VERSION'] = '4.2'
          end
      end
  end
  
end
