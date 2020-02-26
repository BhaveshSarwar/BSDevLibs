Pod::Spec.new do |s|

  s.name         = "BSDevLibs"
  s.version      = "0.0.1"
  s.summary      = "A CocoaPods library written in Swift"

  s.description  = <<-DESC
This CocoaPods library helps you perform calculation.
                   DESC

  s.homepage     = "https://github.com/BhaveshSarwar/BSDevLibs.git"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Bhavesh" => "bhavesh7sarwar@gmail.com" }

  s.ios.deployment_target = "12.1"
  s.swift_version = "4.2"

  s.source        = { :git => "https://github.com/jeantimex/SwiftyLib.git", :tag => "#{s.version}" }
  s.source_files  = "BSDevLibs/**/*.{h,m,swift}"

  s.subspec "BSDLNetworkManager" do |component|
    component.ios.deployment_target = '10.0'
    component.source_files = "BSDevLibs/#{component.base_name}/Source/*"
    component.dependency 'Alamofire', '~> 4.8'
  end

end