Pod::Spec.new do |spec|
  spec.name = 'HiIOSGitHubTrending'
  spec.version = '4.0.0-alpha.1'
  spec.summary = 'Injectable GitHub Trending HTML contract and parser for HiIOS.'
  spec.homepage = 'https://github.com/tospery/HiIOS'
  spec.license = { :type => 'MIT', :file => 'LICENSE' }
  spec.author = { 'YangJianxiang' => 'tospery@gmail.com' }
  spec.source = { :git => 'https://github.com/tospery/HiIOS.git', :tag => spec.version.to_s }
  spec.ios.deployment_target = '17.0'
  spec.swift_version = '6.0'
  spec.source_files = 'Sources/HiIOSGitHubTrending/**/*.swift'
  spec.frameworks = 'Foundation'
  spec.dependency 'HiIOSNetwork', spec.version.to_s
end
