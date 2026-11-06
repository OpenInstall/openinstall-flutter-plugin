#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'openinstall_flutter_plugin'
  s.version          = '0.0.1'
  s.summary          = 'A iOS flutter plugin for OpenInstall.'
  s.description      = <<-DESC
A iOS flutter plugin for OpenInstall.
                       DESC
  s.homepage         = 'https://openinstall.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'David' => 'david111@openinstall.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'

  s.vendored_frameworks = 'libOpenInstallSDK.xcframework'
  s.static_framework = true

  s.ios.deployment_target = '8.0'
end

