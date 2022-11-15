Pod::Spec.new do |s|
  s.name             = 'HiIOS'
  s.version          = '1.0.0'
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
  s.frameworks = 'UIKit'
  s.source_files = 'HiIOS/**/*'

end
