# Lots of inspiration from:
# - https://github.com/rgl/windows-domain-controller-vagrant
# - https://github.com/UNT-CAS/Vagrant-AD-Lab
# - https://github.com/clong/DetectionLab

# Useful commands to cleanup these files
# - ruby-beautify --overwrite --spaces Vagrantfile
# - jq -S < boxes.json > blah.json && mv blah.json boxes.json

require 'json'

# This bit stolen from https://stackoverflow.com/a/30225093
class ::Hash
 def deep_merge(second)
  merger = proc { |_, v1, v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : Array === v1 && Array === v2 ? v1 | v2 : [:undefined, nil, :nil].include?(v2) ? v1 : v2 }
  merge!(second.to_h, &merger)
 end
end

# Setup the box defintions
boxes = JSON.load File.new(File.expand_path("../boxes.json", __FILE__))
# Support a local overrides file that's not in version control
if File.file?(File.expand_path("../local.json", __FILE__))
 boxes.deep_merge(JSON.load File.new(File.expand_path("../local.json", __FILE__)))
end
# Move out the default options for all boxes
default = boxes["_default"]
boxes.delete("_default")

# Display small table about boxes, also check for IP conflicts
IPs = {}
HEADERFORMAT = "%-9s\t%-15s\t%-7s"
ROWFORMAT = "%-9s\t%-15s\t%4dMB"
IPCONFLICT = false
puts "Configured machines:"
puts
puts HEADERFORMAT % %w[System IP Memory]
boxes.keys.sort.each do |boxname|
    box = default.clone()
    box.deep_merge(boxes[boxname])
	ip = box["ip"]
	if IPs[ip]
		ip = ip + " CONFLICT"
		IPCONFLICT = true
	else
		IPs[ip] = boxname
	end
	puts ROWFORMAT % [boxname, ip, box["memory"]]
end

if IPCONFLICT
	puts "There's an IP conflict that must be resolved before continuing."
	exit 1
end
puts

# Actually configure vagrant
Vagrant.configure("2") do |config|
 boxes.keys.sort.each do |boxname|
  # merge the box defintion with the default values
  box = default.clone()
  box.deep_merge(boxes[boxname])

  config.vm.define boxname do |cfg|
   cfg.vm.box = box["image"]
   if box["version"]
     cfg.vm.box_version = box["version"]
   end
   cfg.vm.boot_timeout = 1800

   cfg.vm.hostname = boxname

   # use the plaintext WinRM transport and force it to use basic authentication.
   cfg.winrm.transport = :plaintext
   cfg.winrm.basic_auth_only = true

   if not ENV["VAGRANT_PASS"].nil?
    cfg.winrm.password = ENV["VAGRANT_PASS"]
   end

   if box["os"] == "windows"
    cfg.vm.communicator = "winrm"
   end
   if box["gateway"]
    cfg.vm.network :private_network, ip: box["ip"], gateway: box["gateway"], dns: box["dns"]
   else
    cfg.vm.network :private_network, ip: box["ip"]
   end

   box["ports"].each do |port|
    cfg.vm.network "forwarded_port", guest: port["guest"], host: port["host"]
   end

   box["scripts"].each do |script|
    if File.file?("scripts/" + script)
     cfg.vm.provision "shell", path: "scripts/" + script
    else
     cfg.vm.provision "shell", inline: script
    end
   end

   cfg.vm.provider "virtualbox" do |vb, override|
    vb.name = boxname
    vb.gui = !box["headless"]
    vb.customize ["modifyvm", :id, "--memory", box["memory"]]
    vb.customize ["modifyvm", :id, "--cpus", 2]
    vb.customize ["modifyvm", :id, "--vram", "32"]
    vb.customize ["modifyvm", :id, "--clipboard-mode", "bidirectional"]
    vb.customize ["setextradata", "global", "GUI/SuppressMessages", "all"]
    vb.customize ["modifyvm", :id, "--description", box["description"] + "\n\n" + "ip="+box["ip"] + "\nnetkoth.nic=2\nnetkoth.mode=ignore"]
   end

   cfg.vm.synced_folder ".", "/vagrant", disabled: true
   box["folders"].each do |folder|
    cfg.vm.synced_folder folder["host"], folder["guest"]
   end

  end
 end

end
