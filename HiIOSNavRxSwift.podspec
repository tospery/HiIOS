Pod::Spec.new do |spec|
  spec.name = 'HiIOSNavRxSwift'
  spec.version = '4.0.0-alpha.1'
  spec.summary = 'HiIOSNavRxSwift module of the reusable HiIOS library.'
  spec.homepage = 'https://github.com/tospery/HiIOS'
  spec.license = { :type => 'MIT', :file => 'LICENSE' }
  spec.author = { 'YangJianxiang' => 'tospery@gmail.com' }
  spec.source = { :git => 'https://github.com/tospery/HiIOS.git', :tag => spec.version.to_s }
  spec.ios.deployment_target = '17.0'
  spec.swift_version = '6.0'
  spec.source_files = 'Sources/HiIOSNavRxSwift/**/*.swift'
  spec.dependency 'HiIOSNavCore', '4.0.0-alpha.1'
  spec.dependency 'RxSwift', '6.9.0'
  spec.dependency 'URLNavigator-Hi', '2.5.1-v1'
end
