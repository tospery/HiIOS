source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '13.0'
use_frameworks!
inhibit_all_warnings!

target 'IOSTemplate' do

  # pod 'HiIOS', :path => '../HiIOS'
  pod 'HiIOS', '1.0.1'

  # Base
  pod 'RxOptional', '5.0.2'
  pod 'RxSwiftExt', '6.2.1'
  pod 'RxGesture', '4.0.4'
  pod 'RxViewController', '2.0.0'
  pod 'IQKeyboardManagerSwift', '6.5.10'
  pod 'ReusableKit-Hi/RxSwift', '3.0.0-v4'
  pod 'DefaultsKit', '0.2.0'
  pod 'R.swift', '6.1.0'
  pod 'SwiftLint', '0.46.2'
  pod 'Umbrella/Core', '0.12.0'
  pod 'SnapKit', '5.6.0'
  
  # Advanced
  pod 'Toast-Swift', '5.0.1'
  pod 'SwiftEntryKit', '2.0.0'
  
  # Platform
  # pod 'MLeaksFinder', '1.0.0'
  # pod 'FLEX', '3.0.0'

end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
        end
    end
end
