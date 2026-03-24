#
# Be sure to run `pod lib lint BeaconIpmagix.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'BeaconIpmagix'
  s.version          = '1.3.0'
  s.summary          = 'A Bluetooth beacon library.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
iBeacon opens a world of possibilities for location awareness, and countless opportunities for interactivity between iOS devices and iBeacon hardware.
                       DESC

  s.homepage         = 'https://github.com/Mohamed-AbdulRaouf/BeaconIpmagix'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Raouf' => 'mohamed.a.raouf@icloud.com' }
  s.source           = { :git => 'https://github.com/Mohamed-AbdulRaouf/BeaconIpmagix.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '12.4'
  s.swift_versions = '5.3.2'
  s.source_files = 'BeaconIpmagix/Classes/**/*'
  s.static_framework = true
  s.requires_arc = true
  s.pod_target_xcconfig = { 'PRODUCT_BUNDLE_IDENTIFIER': 'com.Ipmagix.BeaconIpmagix' }

  # s.resource_bundles = {
  #   'BeaconIpmagix' => ['BeaconIpmagix/Assets/*.png']
  # }

#  s.public_header_files = 'Pod/Classes/**/*.h'
#  s.requires_arc = true
  s.frameworks = 'CoreLocation', 'CoreBluetooth'
  # s.dependency 'AFNetworking', '~> 2.3'
end
