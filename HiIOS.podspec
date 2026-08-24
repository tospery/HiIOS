Pod::Spec.new do |spec|
  spec.name = 'HiIOS'
  spec.version = '4.0.0-alpha.1'
  spec.summary = 'Convenient CocoaPods entry points for HiIOS products.'
  spec.description = <<-DESC
    HiIOS is a dependency-only meta pod that installs independently importable HiIOS product modules.
  DESC
  spec.homepage = 'https://github.com/tospery/HiIOS'
  spec.license = { :type => 'MIT', :file => 'LICENSE' }
  spec.author = { 'YangJianxiang' => 'tospery@gmail.com' }
  spec.source = { :git => 'https://github.com/tospery/HiIOS.git', :tag => spec.version.to_s }
  spec.ios.deployment_target = '17.0'
  spec.swift_version = '6.0'
  spec.default_subspecs = 'Core', 'Log', 'Persistence', 'Device'

  spec.subspec 'Core' do |subspec|
    subspec.dependency 'HiIOSCore', spec.version.to_s
  end

  spec.subspec 'Log' do |subspec|
    subspec.dependency 'HiIOSLog', spec.version.to_s
  end

  spec.subspec 'Persistence' do |subspec|
    subspec.dependency 'HiIOSPersistence', spec.version.to_s
  end

  spec.subspec 'Device' do |subspec|
    subspec.dependency 'HiIOSDevice', spec.version.to_s
  end
end
