# -*- mode: ruby -*-
# vi: set ft=ruby :

# Lots of inspiration from:
# - https://github.com/rgl/windows-domain-controller-vagrant
# - https://github.com/UNT-CAS/Vagrant-AD-Lab
# - https://github.com/clong/DetectionLab

# Useful commands to cleanup these files
# - ruby-beautify --overwrite --spaces Vagrantfile
# - jq -S < boxes.json > blah.json && mv blah.json boxes.json

ENV['no_proxy'] = '*' # for winrm sometimes
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
default = {
 "cpus" => 2,
 "groups" => [],
 "image" => "generic/debian11",
 "memory" => 1,
 "os" => "linux",
 "ports" => [],
 "tld" => "lab",
 "scripts" => [],
 "files" => [],
 "folders" => [],
 "skip_tags" => []
}
default.deep_merge(boxes["_default"])
boxes.delete("_default")
groups = {}
boxes.keys.sort.each do |boxname|
 box = default.clone()
 box.deep_merge(boxes[boxname])

 if !groups[box["os"]]
  groups[box["os"]] = []
 end
 groups[box["os"]].append(boxname)
 groups[box["os"]].append(boxname + "." + box["tld"])

 if !groups[boxname]
  groups[boxname] = []
 end
 groups[boxname].append(boxname)
 groups[boxname].append(boxname + "." + box["tld"])

 box["groups"].each do |g|
  if ! groups[g]
   groups[g] = []
  end
  groups[g].append(boxname)
  groups[g].append(boxname + "." + box["tld"])
 end
end
groups["windows:vars"] = { "ansible_winrm_server_cert_validation" => "ignore" }

# Display small table about boxes, also check for IP conflicts
IPs = {}
HEADERFORMAT = "%-9s\t%-15s\t%-7s"
ROWFORMAT = "%-9s\t%-15s\t%5dGB"
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
   cfg.dns.tld = box["tld"]

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
   if box["os"] == "windows"
    cfg.vm.provision "shell", privileged: false, name: "Schedule setting secondary interface", inline: <<~SHELL
   try {
       UnRegister-ScheduledTask SetIPConfig -Confirm:$false -EA SilentlyContinue
       $A = New-ScheduledTaskAction -Execute "netsh.exe" -Argument "int ip set address `\"Ethernet 2`\" static #{box["ip"]} 255.255.255.0"
       $T = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1)
       $D = New-ScheduledTask -Action $A -Trigger $T
       Register-ScheduledTask SetIPConfig -InputObject $D
     }
     catch {"Unsupported powershell version: " + $_}
     SHELL
   end

   box["ports"].each do |port|
    cfg.vm.network "forwarded_port", guest: port["guest"], host: port["host"]
   end

   if box["os"] == "linux"
    cfg.vm.provision "shell", inline: "grep -q dns-nameserver /etc/network/interfaces && (sed -i /dns-nameserver/d /etc/network/interfaces && systemctl restart ifup@eth0.service) || true"
   end

   box["files"].each do |f|
    cfg.vm.provision "file", source: "files/" + f["host"], destination: f["guest"]
   end

   box["scripts"].each do |script|
    if File.file?("scripts/" + script)
     cfg.vm.provision "shell", path: "scripts/" + script
    else
     cfg.vm.provision "shell", inline: script
    end
   end

   if(File.exist?(boxname+".yml"))
    cfg.vm.provision "ansible" do |ansible|
     # force http incase the winrm port isn't 5985, which will happen with multiple windows systems.
     ansible.host_vars = { boxname => {"ansible_winrm_scheme" => "http" } }
     # TODO autodetect this vs the system ansible-playbook command
     ansible.playbook_command = File.expand_path("../venv/bin/ansible-playbook", __FILE__)
     ansible.verbose = "v"
     ansible.playbook = boxname + ".yml"
     ansible.extra_vars = { "ansible_ssh_user" => "vagrant"}
     ansible.extra_vars.deep_merge(box["extra_vars"])
     ansible.groups = groups
     ansible.skip_tags = ["no-vagrant"] + box["skip_tags"]
    end
   end

   cfg.vm.synced_folder ".", "/vagrant", disabled: true
   box["folders"].each do |folder|
    cfg.vm.synced_folder folder["host"], folder["guest"]
   end

   cfg.vm.provider "virtualbox" do |vb, override|
    vb.name = boxname
    vb.gui = !box["headless"]
    if box["os"] == "windows"
     vb.customize ["modifyvm", :id, "--graphicscontroller", "vboxsvga"]
    end
    vb.customize ["modifyvm", :id, "--memory", box["memory"] * 1024]
    vb.customize ["modifyvm", :id, "--cpus", 2]
    vb.customize ["modifyvm", :id, "--vram", "32"]
    vb.customize ["modifyvm", :id, "--accelerate2dvideo", "on"]
    vb.customize ["modifyvm", :id, "--audio", "coreaudio"]
    vb.customize ["modifyvm", :id, "--clipboard-mode", "bidirectional"]
    vb.customize ["modifyvm", :id, "--paravirtprovider", "hyperv"]
    vb.customize ["modifyvm", :id, "--nested-hw-virt", "on"]
    vb.customize ["setextradata", "global", "GUI/SuppressMessages", "all"]
    vb.customize ["modifyvm", :id, "--description", box["description"] + "\n\n" + "ip="+box["ip"] + "\nnetkoth.nic=2\nnetkoth.mode=ignore"]
   end
   cfg.vm.provider "vmware_desktop" do |vmware|
    vmware.vmx["ethernet0.pcislotnumber"] = "33"
   end

  end
 end

end
