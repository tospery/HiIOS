Pod::Spec.new do |spec|
  spec.name = 'HiIOSCore'
  spec.version = '4.0.0-alpha.1'
  spec.summary = 'Stable Foundation-only contracts for HiIOS.'
  spec.description = <<-DESC
    HiIOSCore provides stable, concurrency-safe value and failure contracts shared by HiIOS products.
  DESC
  spec.homepage = 'https://github.com/tospery/HiIOS'
  spec.license = { :type => 'MIT', :file => 'LICENSE' }
  spec.author = { 'YangJianxiang' => 'tospery@gmail.com' }
  spec.source = { :git => 'https://github.com/tospery/HiIOS.git', :tag => spec.version.to_s }
  spec.ios.deployment_target = '17.0'
  spec.swift_version = '6.0'
  spec.source_files = 'Sources/HiIOSCore/**/*.swift'
  spec.frameworks = 'Foundation'
end
