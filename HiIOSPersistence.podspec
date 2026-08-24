Pod::Spec.new do |spec|
  spec.name = 'HiIOSPersistence'
  spec.version = '4.0.0-alpha.1'
  spec.summary = 'Secure persistence primitives for HiIOS.'
  spec.description = <<-DESC
    HiIOSPersistence provides a narrow Keychain seam with stable errors and a system Security adapter.
  DESC
  spec.homepage = 'https://github.com/tospery/HiIOS'
  spec.license = { :type => 'MIT', :file => 'LICENSE' }
  spec.author = { 'YangJianxiang' => 'tospery@gmail.com' }
  spec.source = { :git => 'https://github.com/tospery/HiIOS.git', :tag => spec.version.to_s }
  spec.ios.deployment_target = '17.0'
  spec.swift_version = '6.0'
  spec.source_files = 'Sources/HiIOSPersistence/**/*.swift'
  spec.frameworks = 'Foundation', 'Security'
  spec.dependency 'HiIOSCore', spec.version.to_s
end
