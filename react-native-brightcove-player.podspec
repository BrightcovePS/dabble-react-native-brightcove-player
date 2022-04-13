require 'json'
package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |s|
  s.name                = "react-native-brightcove-player"
  s.version             = package["version"]
  s.description         = package["description"]
  s.summary             = package["description"]
  s.homepage            = "https://github.com/BrightcovePS/react-native-brightcove-player#readme"
  s.license             = package['license']
  s.authors             = "Brightcove Global Services"
  s.platform            = :ios, "11.0"

  s.source              = { :git => "https://github.com/BrightcovePS/react-native-brightcove-player#readme" }
  s.source_files        = 'ios/**/*.{h,m,swift, plist}'
  s.resources           = 'iOS/**/*.{png,jpeg,jpg,storyboard,xib,xcassets,json,otf}'
  s.swift_version       =  '4.2'

  s.dependency          'React'
  s.dependency          'Brightcove-Player-GoogleCast'
  s.static_framework    = false
  s.vendored_frameworks = 'RCTBrightcovePlayer.framework'
end
