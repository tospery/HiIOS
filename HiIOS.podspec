Pod::Spec.new do |spec|
  spec.name = 'HiIOS'
  spec.version = '4.0.0-alpha.1'
  spec.summary = 'Convenient dependency entry for HiIOS modules.'
  spec.description = 'Select independently importable HiIOS modules with CocoaPods.'
  spec.homepage = 'https://github.com/tospery/HiIOS'
  spec.license = { :type => 'MIT', :file => 'LICENSE' }
  spec.author = { 'YangJianxiang' => 'tospery@gmail.com' }
  spec.source = { :git => 'https://github.com/tospery/HiIOS.git', :tag => spec.version.to_s }
  spec.ios.deployment_target = '17.0'
  spec.swift_version = '6.0'
  spec.default_subspecs = 'Core', 'NetCombine', 'NavCombine', 'Store', 'SuiteCore', 'Symbols'
  spec.subspec 'Base' do |subspec|
    subspec.dependency 'HiIOSBase', spec.version.to_s
  end
  spec.subspec 'Core' do |subspec|
    subspec.dependency 'HiIOSCore', spec.version.to_s
  end
  spec.subspec 'NetCore' do |subspec|
    subspec.dependency 'HiIOSNetCore', spec.version.to_s
  end
  spec.subspec 'NetRxSwift' do |subspec|
    subspec.dependency 'HiIOSNetRxSwift', spec.version.to_s
  end
  spec.subspec 'NetCombine' do |subspec|
    subspec.dependency 'HiIOSNetCombine', spec.version.to_s
  end
  spec.subspec 'NavCore' do |subspec|
    subspec.dependency 'HiIOSNavCore', spec.version.to_s
  end
  spec.subspec 'NavRxSwift' do |subspec|
    subspec.dependency 'HiIOSNavRxSwift', spec.version.to_s
  end
  spec.subspec 'NavCombine' do |subspec|
    subspec.dependency 'HiIOSNavCombine', spec.version.to_s
  end
  spec.subspec 'Store' do |subspec|
    subspec.dependency 'HiIOSStore', spec.version.to_s
  end
  spec.subspec 'SuiteCore' do |subspec|
    subspec.dependency 'HiIOSSuiteCore', spec.version.to_s
  end
  spec.subspec 'Symbols' do |subspec|
    subspec.source_files = 'Sources/HiIOS/**/*.swift'
    subspec.dependency 'SFSafeSymbols', '7.0.0'
  end
  spec.subspec 'SuiteLogOSLog' do |subspec|
    subspec.dependency 'HiIOSSuiteLogOSLog', spec.version.to_s
  end
  spec.subspec 'SuiteLogSwiftyBeaver' do |subspec|
    subspec.dependency 'HiIOSSuiteLogSwiftyBeaver', spec.version.to_s
  end
  spec.subspec 'GHTrending' do |subspec|
    subspec.dependency 'HiIOSGHTrending', spec.version.to_s
  end
end
