Pod::Spec.new do |s|
  s.name             = "NSDictionary-HYPNestedAttributes"
  s.summary          = "NSDictionary category that converts the flat relationships in a dictionary to a nested attributes format"
  s.version          = "0.4"
  s.homepage         = "https://github.com/hyperoslo/NSDictionary-HYPNestedAttributes"
  s.license          = 'MIT'
  s.author           = { "Hyper Interaktiv AS" => "ios@hyper.no" }
  s.source           = { :git => "https://github.com/hyperoslo/NSDictionary-HYPNestedAttributes.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/hyperoslo'
  s.platform     = :ios, '7.0'
  s.requires_arc = true
  s.source_files = 'Source/**/*'
  s.dependency 'NSString-HYPRelationshipParser', '~> 0.4'
end
