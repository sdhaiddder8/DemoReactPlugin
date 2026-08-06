require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |s|
  s.name         = "ekey-react-native-sdk"
  s.version      = package['version']
  s.summary      = package['description']
  s.license      = package['license']
  s.authors      = "NEC"
  s.homepage     = "https://example.com/ekey-react-native-sdk"
  s.platforms    = { ios: "14.0" }
  s.source       = { :path => "." }
  s.source_files = "ios/**/*.{swift,h,mm}"
  s.vendored_frameworks = "Frameworks/EkeySDK.xcframework"
  # EkeySdkModule.h pulls in the codegen'd Obj-C++-only EkeySdkSpec.h. Keep it out of the
  # pod's public/umbrella header (generated because this pod also has Swift files), otherwise
  # Clang compiles the umbrella as plain Obj-C and trips the header's __cplusplus guard.
  s.private_header_files = "ios/EkeySdkModule.h"
  s.swift_version = "5.0"

  s.dependency "React-Core"

  install_modules_dependencies(s)
end
