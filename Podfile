use_frameworks!

target 'Unifai' do
    pod 'SwiftyJSON', :git => 'https://github.com/SwiftyJSON/SwiftyJSON.git'
    pod 'Alamofire', '~> 4.0'
    pod 'DateTools'
    pod 'ActiveLabel'
    pod 'SnapKit', '~> 3.0.2'
    pod 'AlertOnboarding'
    pod "GSImageViewerController"
    pod 'Charts', :git => 'https://github.com/danielgindi/Charts'
    pod "DGElasticPullToRefresh"
    pod 'expanding-collection'
    pod 'DynamicColor', '~> 3.1.0'
    pod "RFAboutView-Swift", '~> 2.0.1'
    pod 'AlamofireImage', '~> 3.1'
    pod 'PKHUD', :git => 'https://github.com/toyship/PKHUD.git'
    pod 'Result', '~> 3.0.0'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end
