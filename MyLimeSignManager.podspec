Pod::Spec.new do |s|
  s.name         = "MyLimeSignManager"
  s.version      = "1.0.3"
  s.summary      = "Sign generator for MyLime"
  s.description  = <<-DESC
    Demo
  DESC
  s.homepage     = "https://github.com/cbarbera80/MyLimeSignManager"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Claudio Barbera" => "barbera.claudio@gmail.com" }
  s.ios.deployment_target = "13.0"
  s.source       = { :git => "https://github.com/cbarbera80/MyLimeSignManager", :tag => s.version.to_s }
  s.source_files  = "Sources/**/*"
  s.frameworks  = "Foundation"
  s.swift_versions = ['5.1']
end
