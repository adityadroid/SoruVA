# Uncomment this line to define a global platform for your project
# platform :ios, '9.0'

target 'soru' do
    pod 'BMSCore', '~> 2.0'
    pod 'ObjectMapper', '~> 2.0.0'

  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  pod "SwiftSpinner", '~> 1.1.0'
  pod "JSQMessagesViewController", '~> 7.3.4'

  # Pods for soru

  target 'soruTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'soruUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end
post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.2'
        end
    end
end
