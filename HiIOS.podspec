Pod::Spec.new do |s|
  s.name             = 'HiIOS'
  s.version          = '1.0.1'
  s.summary          = 'iOS App Framework.'
  s.description      = <<-DESC
						iOS App Framework using Swift.
                       DESC
  s.homepage         = 'https://github.com/tospery/HiIOS'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'YangJianxiang' => 'tospery@gmail.com' }
  s.source           = { :git => 'https://github.com/tospery/HiIOS.git', :tag => s.version.to_s }

  s.requires_arc = true
  s.swift_version = '5.0'
  s.ios.deployment_target = '11.0'
  s.frameworks = 'UIKit', 'CoreGraphics'
  
  s.subspec 'Core' do |ss|
    ss.source_files = 'HiIOS/Core/**/*'
  	ss.dependency 'QMUIKit/QMUICore', '4.5.1'
  	ss.dependency 'FCUUID', '1.3.1'
  	ss.dependency 'SwiftyBeaver', '1.9.5'
  	ss.dependency 'ObjectMapper-Hi', '4.2.0-v1'
  	ss.dependency 'SwifterSwift-Hi', '5.3.0-v1'
  end
  
  s.subspec 'Cache' do |ss|
    ss.source_files = 'HiIOS/Cache/**/*'
  	ss.dependency 'HiIOS/Core'
  	ss.dependency 'Cache', '6.0.0'
  end
  
  s.subspec 'Router' do |ss|
    ss.source_files = 'HiIOS/Router/**/*'
  	ss.dependency 'HiIOS/Core'
  	ss.dependency 'RxSwift', '~> 6.0'
  	ss.dependency 'RxCocoa', '~> 6.0'
  	ss.dependency 'URLNavigator', '2.4.1'
  end
  
  s.subspec 'Network' do |ss|
    ss.source_files = 'HiIOS/Network/**/*'
  	ss.dependency 'HiIOS/Core'
  	ss.dependency 'RxRelay', '~> 6.0'
  	ss.dependency 'Moya/RxSwift', '15.0.0'
  end
  
  s.subspec 'Theme' do |ss|
    ss.source_files = 'HiIOS/Theme/**/*'
  	ss.dependency 'HiIOS/Core'
  	ss.dependency 'RxTheme', '6.0.0'
  end
  
  s.subspec 'Resources' do |ss|
    ss.resource_bundles = {'Resources' => ['HiIOS/Resources/*.*']}
  end
  
  s.subspec 'Components' do |ss|
    ss.subspec 'JSBridge' do |sss|
      sss.source_files = 'HiIOS/Components/JSBridge/**/*'
  	  sss.frameworks = 'WebKit'
    end
  end
  
  s.subspec 'Frame' do |ss|
    ss.source_files = 'HiIOS/Frame/**/*'
  	ss.dependency 'HiIOS/Core'
  	ss.dependency 'HiIOS/Cache'
  	ss.dependency 'HiIOS/Theme'
  	ss.dependency 'HiIOS/Router'
  	ss.dependency 'HiIOS/Network'
  	ss.dependency 'HiIOS/Resources'
  	ss.dependency 'HiIOS/Components/JSBridge'
  	ss.dependency 'RxDataSources', '5.0.0'
  	ss.dependency 'NSObject+Rx', '5.2.2'
  	ss.dependency 'ReactorKit', '3.2.0'
  	ss.dependency 'BonMot', '6.1.1'
  	ss.dependency 'Kingfisher', '6.3.1'
  	ss.dependency 'DZNEmptyDataSet', '1.8.1'
  	ss.dependency 'MJRefresh', '3.7.5'
  end

end
