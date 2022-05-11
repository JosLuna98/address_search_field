#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint address_search_field.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'address_search_field'
  s.version          = '5.0.0'
  s.summary          = 'An address search field which helps to autocomplete an address by a reference. It can be used to get Directions beetwen two points.'
  s.description      = <<-DESC
  An address search field which helps to autocomplete an address by a reference. It can be used to get Directions beetwen two points.
                       DESC
  s.homepage         = 'https://github.com/JosLuna98/address_search_field'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'JosLuna98' => 'josluna1098@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '9.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
