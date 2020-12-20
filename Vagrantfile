# -*- mode: ruby -*-
# vi: set ft=ruby :

# Check if the required plugins are installed.
unless Vagrant.has_plugin?('vagrant-reload')
  puts 'vagrant-reload plugin not found, installing'
  system 'vagrant plugin install vagrant-reload'
  # Restart the process with the plugin installed.
  exec "vagrant #{ARGV.join(' ')}"
end

packer_boxes = [
  "centos_7_distro",
  "centos_7_upstream",
  "centos_8_upstream",
  "rhel_7_distro",
  "rhel_8_upstream",
  "ubuntu_1804_distro",
  "ubuntu_1804_upstream",
  "ubuntu_2004_distro",
  "ubuntu_2004_upstream",
  "arch_0_distro"
]

def get_windows_vm_box_version()
  # We're pinning to this specific version due to recent Docker versions (above 19.03.05) being broken
  # (see https://gitlab.com/gitlab-org/gitlab-runner/-/issues/27115)
  '2020.04.15'
end

Vagrant.configure("2") do |config|
  config.vm.provider "virtualbox" do |v|
    v.memory = 512
    v.cpus = 1
  end
  config.vm.boot_timeout = 600

  packer_boxes.each do |(box)|
    config.vm.define box do |cfg|
      cfg.vm.box = box
      cfg.vm.box_url = "file://" + box + "/package.box"
      cfg.vm.provider "virtualbox" do |v|
        v.name = box
      end
    end
  end

 # Windows boxes and scripts based on: https://gitlab.com/gitlab-org/gitlab-runner/-/blob/master/Vagrantfile
 config.vm.define 'windows_server', primary: true do |cfg|
    cfg.vm.box = 'StefanScherer/windows_2019_docker'
    cfg.vm.box_version = get_windows_vm_box_version()
    cfg.vm.communicator = 'winrm'
    cfg.vm.provider "virtualbox" do |v|
      v.gui = false
      v.memory = '2048'
      v.cpus = 1
      v.linked_clone = true
      v.customize ['modifyvm', :id, '--nested-hw-virt', 'on']
    end

    cfg.vm.synced_folder '.', 'C:\GitLab-Runner'

    cfg.vm.provision 'shell', path: 'scripts/base.ps1'
    cfg.vm.provision 'shell', path: 'scripts/install_PSWindowsUpdate.ps1'
    cfg.vm.provision 'shell', path: 'scripts/windows_update.ps1'

    # Restart the box to install the updates, and update again.
    cfg.vm.provision :reload
    cfg.vm.provision 'shell', path: 'scripts/windows_update.ps1'
    cfg.vm.provision :reload

    cfg.vm.provision 'shell', path: 'scripts/enable_sshd.ps1'
    cfg.vm.provision :reload
    cfg.vm.provision 'shell', path: 'scripts/start_sshd.ps1'
  end

  config.vm.define 'windows_10', autostart: false do |cfg|
    cfg.vm.box = 'StefanScherer/windows_10'
    cfg.vm.box_version = get_windows_vm_box_version()
    cfg.vm.communicator = 'winrm'
    cfg.vm.provider "virtualbox" do |v|
      v.gui = false
      v.memory = '2048'
      v.cpus = 1
      v.linked_clone = true
      v.customize ['modifyvm', :id, '--nested-hw-virt', 'on']
    end

    cfg.vm.synced_folder '.', 'C:\GitLab-Runner'

    cfg.vm.provision 'shell', path: 'scripts/base.ps1'
    cfg.vm.provision 'shell', path: 'scripts/docker_desktop.ps1'
    cfg.vm.provision 'shell', path: 'scripts/enable_developer_mode.ps1'

    cfg.vm.provision 'shell', path: 'scripts/enable_sshd.ps1'
    cfg.vm.provision :reload
    cfg.vm.provision 'shell', path: 'scripts/start_sshd.ps1'
  end
end
