Pod::Spec.new do |spec|
  spec.name = 'HiIOSLog'
  spec.version = '4.0.0-alpha.1'
  spec.summary = 'Privacy-aware logging contracts for HiIOS.'
  spec.description = <<-DESC
    HiIOSLog provides structured records, release redaction, level filtering, and a private Apple Logger adapter.
  DESC
  spec.homepage = 'https://github.com/tospery/HiIOS'
  spec.license = { :type => 'MIT', :file => 'LICENSE' }
  spec.author = { 'YangJianxiang' => 'tospery@gmail.com' }
  spec.source = { :git => 'https://github.com/tospery/HiIOS.git', :tag => spec.version.to_s }
  spec.ios.deployment_target = '17.0'
  spec.swift_version = '6.0'
  spec.source_files = 'Sources/HiIOSLog/**/*.swift'
  spec.frameworks = 'Foundation', 'OSLog'
end
