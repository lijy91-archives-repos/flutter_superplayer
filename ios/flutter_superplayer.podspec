#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_superplayer.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_superplayer'
  s.version          = '0.0.1'
  s.summary          = 'A new flutter plugin project.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'SDWebImage', '~> 5.0'
  s.platform = :ios, '9.0'

  s.default_subspec = 'SuperPlayer_Professional'

  s.subspec "SuperPlayer_Professional" do |ss|
    ss.dependency 'AFNetworking', '~> 4.0'
    ss.dependency 'Masonry'
    ss.dependency 'TXLiteAVSDK_Professional'
    ss.source_files = 'SuperPlayer/**/*.{h,m}'
    ss.private_header_files = 'SuperPlayer/Utils/TXBitrateItemHelper.h', 'SuperPlayer/Views/SuperPlayerView+Private.h'
    ss.resource = 'SuperPlayer/Resource/*'
  end

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  s.static_framework = true
end

