Pod::Spec.new do |spec|
  spec.name = 'HiIOSStore'
  spec.version = '4.0.0-alpha.1'
  spec.summary = 'Selectable HiIOSStore modules.'
  spec.homepage = 'https://github.com/tospery/HiIOS'
  spec.license = { :type => 'MIT', :file => 'LICENSE' }
  spec.author = { 'YangJianxiang' => 'tospery@gmail.com' }
  spec.source = { :git => 'https://github.com/tospery/HiIOS.git', :tag => spec.version.to_s }
  spec.ios.deployment_target = '17.0'
  spec.swift_version = '6.0'
  spec.default_subspecs = 'Core', 'Keychain', 'Defaults', 'File'
  spec.subspec 'Core' do |subspec|
    subspec.dependency 'HiIOSStoreCore', spec.version.to_s
  end
  spec.subspec 'Keychain' do |subspec|
    subspec.dependency 'HiIOSStoreKeychain', spec.version.to_s
  end
  spec.subspec 'Defaults' do |subspec|
    subspec.dependency 'HiIOSStoreDefaults', spec.version.to_s
  end
  spec.subspec 'File' do |subspec|
    subspec.dependency 'HiIOSStoreFile', spec.version.to_s
  end
end
