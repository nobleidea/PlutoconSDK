#
# Be sure to run `pod lib lint PlutoconSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'PlutoconSDK'
  s.version          = '1.0.0'
  s.summary          = 'PlutoconSDK for iOS'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'PlutoconSDK for iOS'

  s.homepage         = 'https://github.com/kong-tech/PlutoconSDK-iOS'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'dhhyuk' => 'kongkdh@kong-tech.com' }
  s.source           = { :git => 'https://github.com/kong-tech/PlutoconSDK-iOS.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'

  s.source_files = 'PlutoconSDK/Classes/**/*'
  
  s.frameworks = 'CoreBluetooth'
end
