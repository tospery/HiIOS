Pod::Spec.new do |spec|
  spec.name = 'HiIOSNav'
  spec.version = '4.0.0-alpha.1'
  spec.summary = 'Selectable HiIOSNav modules.'
  spec.homepage = 'https://github.com/tospery/HiIOS'
  spec.license = { :type => 'MIT', :file => 'LICENSE' }
  spec.author = { 'YangJianxiang' => 'tospery@gmail.com' }
  spec.source = { :git => 'https://github.com/tospery/HiIOS.git', :tag => spec.version.to_s }
  spec.ios.deployment_target = '17.0'
  spec.swift_version = '6.0'
  spec.default_subspecs = 'Core'
  spec.subspec 'Core' do |subspec|
    subspec.dependency 'HiIOSNavCore', spec.version.to_s
  end
  spec.subspec 'RxSwift' do |subspec|
    subspec.dependency 'HiIOSNavRxSwift', spec.version.to_s
  end
  spec.subspec 'Combine' do |subspec|
    subspec.dependency 'HiIOSNavCombine', spec.version.to_s
  end
end
