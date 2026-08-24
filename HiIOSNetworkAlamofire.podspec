Pod::Spec.new do |spec|
  spec.name = 'HiIOSNetworkAlamofire'
  spec.version = '4.0.0-alpha.1'
  spec.summary = 'Alamofire transport adapter for HiIOSNetwork.'
  spec.description = <<-DESC
    HiIOSNetworkAlamofire implements the HiIOSNetwork transport seam without exposing Alamofire types.
  DESC
  spec.homepage = 'https://github.com/tospery/HiIOS'
  spec.license = { :type => 'MIT', :file => 'LICENSE' }
  spec.author = { 'YangJianxiang' => 'tospery@gmail.com' }
  spec.source = { :git => 'https://github.com/tospery/HiIOS.git', :tag => spec.version.to_s }
  spec.ios.deployment_target = '17.0'
  spec.swift_version = '6.0'
  spec.source_files = 'Sources/HiIOSNetworkAlamofire/**/*.swift'
  spec.frameworks = 'Foundation'
  spec.dependency 'Alamofire', '5.12.0'
  spec.dependency 'HiIOSLog', spec.version.to_s
  spec.dependency 'HiIOSNetwork', spec.version.to_s
end
