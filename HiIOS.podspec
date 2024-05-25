Pod::Spec.new do |s|
  s.name             = 'HiIOS'
  s.version          = '3.0.0'
  s.summary          = 'iOS App Framework.'
  s.description      = <<-DESC
						iOS App Framework using Swift.
                       DESC
  s.homepage         = 'https://github.com/tospery/HiIOS'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'YangJianxiang' => 'tospery@gmail.com' }
  s.source           = { :git => 'https://github.com/tospery/HiIOS.git', :tag => s.version.to_s }

  s.requires_arc = true
  s.swift_version = '5.3'
  s.ios.deployment_target = '13.0'
  s.frameworks = 'Foundation', 'CoreGraphics', 'UIKit'
  
  s.source_files = 'HiIOS/**/*'
  s.dependency 'HiCore', '~> 1.0'
  s.dependency 'HiNav', '~> 1.0'
  s.dependency 'HiNet', '~> 1.0'
  s.dependency 'HiTheme', '~> 1.0'
  s.dependency 'HiResource', '~> 1.0'
  s.dependency 'HiJSBridge', '~> 1.0'
  s.dependency 'RxOptional', '~> 5.0'
  s.dependency 'RxSwiftExt', '~> 6.0'
  s.dependency 'RxDataSources', '~> 5.0'
  s.dependency 'NSObject+Rx', '~> 5.0'
  s.dependency 'ReactorKit', '~> 3.0'
  s.dependency 'SwifterSwift', '~> 6.0'
  s.dependency 'RxViewController', '~> 2.0'
  s.dependency 'BonMot', '~> 6.0'
  s.dependency 'Kingfisher', '~> 7.0'
  s.dependency 'DZNEmptyDataSet', '~> 1.0'
  s.dependency 'TTTAttributedLabel', '~> 2.0'
  s.dependency 'MJRefresh', '~> 3.0'

end
