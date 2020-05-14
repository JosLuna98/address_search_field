#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint address_search_field.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'address_search_field'
  s.version          = '1.0.0'
  s.summary          = 'A flutter plugin to find an address and its location data.'
  s.description      = <<-DESC
  An address search box that gets nearby addresses by typing a reference, returns an object with place primary data. The object can also find an address using coordinates.
                       DESC
  s.homepage         = 'https://github.com/JosLuna98/address_search_field'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'JosTech.Dev' => 'josluna1098@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '8.0'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  s.swift_version = '5.0'
end
