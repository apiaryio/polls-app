platform :ios, '8.0'
use_frameworks!

target 'Polls' do
  pod 'Hyperdrive', :head
  pod 'SVProgressHUD'
  pod 'VTAcknowledgementsViewController'
  pod 'SimulatorStatusMagic', :configurations => ['Debug']
end

target 'PollsTests' do

end

post_install do |installer|
  # Inject the plist acknowledements file into the resource
  # To be moved to CP plugin: https://github.com/CocoaPods/CocoaPods/issues/2465
  resources = File.read('Pods/Target Support Files/Pods-Polls/Pods-Polls-resources.sh').split("\n")
  rsync_index = resources.index { |line| line =~ /^rsync/ }
  resources.insert(rsync_index, 'install_resource "Target Support Files/Pods-Polls/Pods-Polls-acknowledgements.plist"')
  File.write('Pods/Target Support Files/Pods-Polls/Pods-Polls-resources.sh', resources.join("\n"))
end

class ::Pod::Generator::Acknowledgements
  def specs
    file_accessors.map { |accessor| accessor.spec.root }.uniq.reject do |spec|
      ['VTAcknowledgementsViewController', 'SimulatorStatusMagic'].include?(spec.name)
    end
  end
end

