Pod::Spec.new do |spec|
  spec.name = 'HiIOSGHTrending'
  spec.version = '4.0.0-alpha.1'
  spec.summary = 'HiIOSGHTrending module of the reusable HiIOS library.'
  spec.homepage = 'https://github.com/tospery/HiIOS'
  spec.license = { :type => 'MIT', :file => 'LICENSE' }
  spec.author = { 'YangJianxiang' => 'tospery@gmail.com' }
  spec.source = { :git => 'https://github.com/tospery/HiIOS.git', :tag => spec.version.to_s }
  spec.ios.deployment_target = '17.0'
  spec.swift_version = '6.0'
  spec.source_files = 'Sources/HiIOSGHTrending/**/*.swift'
  spec.dependency 'HiIOSNetCore', '4.0.0-alpha.1'
  spec.dependency 'SwiftSoup', '2.11.3'
end
