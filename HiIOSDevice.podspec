Pod::Spec.new do |spec|
  spec.name = 'HiIOSDevice'
  spec.version = '4.0.0-alpha.1'
  spec.summary = 'Privacy-preserving App Family identity for HiIOS.'
  spec.description = <<-DESC
    HiIOSDevice atomically creates and reads the shared App Family seed without exposing hardware identifiers.
  DESC
  spec.homepage = 'https://github.com/tospery/HiIOS'
  spec.license = { :type => 'MIT', :file => 'LICENSE' }
  spec.author = { 'YangJianxiang' => 'tospery@gmail.com' }
  spec.source = { :git => 'https://github.com/tospery/HiIOS.git', :tag => spec.version.to_s }
  spec.ios.deployment_target = '17.0'
  spec.swift_version = '6.0'
  spec.source_files = 'Sources/HiIOSDevice/**/*.swift'
  spec.frameworks = 'Foundation'
  spec.dependency 'HiIOSCore', spec.version.to_s
  spec.dependency 'HiIOSPersistence', spec.version.to_s
end
