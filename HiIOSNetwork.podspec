Pod::Spec.new do |spec|
  spec.name = 'HiIOSNetwork'
  spec.version = '4.0.0-alpha.1'
  spec.summary = 'Stable HTTP transport contracts for HiIOS.'
  spec.description = <<-DESC
    HiIOSNetwork provides concurrency-safe request, response, header, summary, and transport contracts.
  DESC
  spec.homepage = 'https://github.com/tospery/HiIOS'
  spec.license = { :type => 'MIT', :file => 'LICENSE' }
  spec.author = { 'YangJianxiang' => 'tospery@gmail.com' }
  spec.source = { :git => 'https://github.com/tospery/HiIOS.git', :tag => spec.version.to_s }
  spec.ios.deployment_target = '17.0'
  spec.swift_version = '6.0'
  spec.source_files = 'Sources/HiIOSNetwork/**/*.swift'
  spec.frameworks = 'Foundation'
end
