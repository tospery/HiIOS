Pod::Spec.new do |spec|
  spec.name = 'HiIOSNet'
  spec.version = '4.0.0-alpha.1'
  spec.summary = 'Selectable HiIOSNet modules.'
  spec.homepage = 'https://github.com/tospery/HiIOS'
  spec.license = { :type => 'MIT', :file => 'LICENSE' }
  spec.author = { 'YangJianxiang' => 'tospery@gmail.com' }
  spec.source = { :git => 'https://github.com/tospery/HiIOS.git', :tag => spec.version.to_s }
  spec.ios.deployment_target = '17.0'
  spec.swift_version = '6.0'
  spec.default_subspecs = 'Core'
  spec.subspec 'Core' do |subspec|
    subspec.dependency 'HiIOSNetCore', spec.version.to_s
  end
  spec.subspec 'RxSwift' do |subspec|
    subspec.dependency 'HiIOSNetRxSwift', spec.version.to_s
  end
  spec.subspec 'Combine' do |subspec|
    subspec.dependency 'HiIOSNetCombine', spec.version.to_s
  end
end
