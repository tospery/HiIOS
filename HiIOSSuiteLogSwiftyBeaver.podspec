Pod::Spec.new do |spec|
  spec.name = 'HiIOSSuiteLogSwiftyBeaver'
  spec.version = '4.0.0-alpha.1'
  spec.summary = 'HiIOSSuiteLogSwiftyBeaver module of the reusable HiIOS library.'
  spec.homepage = 'https://github.com/tospery/HiIOS'
  spec.license = { :type => 'MIT', :file => 'LICENSE' }
  spec.author = { 'YangJianxiang' => 'tospery@gmail.com' }
  spec.source = { :git => 'https://github.com/tospery/HiIOS.git', :tag => spec.version.to_s }
  spec.ios.deployment_target = '17.0'
  spec.swift_version = '6.0'
  spec.source_files = 'Sources/HiIOSSuiteLogSwiftyBeaver/**/*.swift'
  spec.dependency 'HiIOSBase', '4.0.0-alpha.1'
  spec.dependency 'SwiftyBeaver', '2.1.1'
end
