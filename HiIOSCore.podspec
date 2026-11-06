Pod::Spec.new do |spec|
  spec.name = 'HiIOSCore'
  spec.version = '4.0.0-alpha.1'
  spec.summary = 'Reusable iOS platform utilities for HiIOS.'
  spec.description = <<-DESC
    HiIOSCore provides reusable iOS platform utilities while HiIOSBase owns language-level contracts.
  DESC
  spec.homepage = 'https://github.com/tospery/HiIOS'
  spec.license = { :type => 'MIT', :file => 'LICENSE' }
  spec.author = { 'YangJianxiang' => 'tospery@gmail.com' }
  spec.source = { :git => 'https://github.com/tospery/HiIOS.git', :tag => spec.version.to_s }
  spec.ios.deployment_target = '17.0'
  spec.swift_version = '6.0'
  spec.source_files = 'Sources/HiIOSCore/**/*.swift'
  spec.dependency 'HiIOSBase', spec.version.to_s
  spec.dependency 'SwifterSwift/SwiftStdlib', '8.0.0'
  spec.dependency 'SwifterSwift/Foundation', '8.0.0'
  spec.dependency 'SwifterSwift/UIKit', '8.0.0'
  spec.dependency 'SwifterSwift/CoreGraphics', '8.0.0'
  spec.dependency 'DeviceKit', '5.10.0'
end
