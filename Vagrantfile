# -*- mode: ruby -*-
# vi: set ft=ruby :

# Check if the required plugins are installed.
unless Vagrant.has_plugin?('vagrant-reload')
  puts 'vagrant-reload plugin not found, installing'
  system 'vagrant plugin install vagrant-reload'
  # Restart the process with the plugin installed.
  exec "vagrant #{ARGV.join(' ')}"
end
unless Vagrant.has_plugin?('vagrant-env')
  puts 'vagrant-env plugin not found, installing'
  system 'vagrant plugin install vagrant-env'
  # Restart the process with the plugin installed.
  exec "vagrant #{ARGV.join(' ')}"
end
unless Vagrant.has_plugin?('winrm')
  puts 'winrm plugin not found, installing'
  system 'vagrant plugin install winrm'
  system 'vagrant plugin install winrm-fs'
  system 'vagrant plugin install winrm-elevated'
  # Restart the process with the plugin installed.
  exec "vagrant #{ARGV.join(' ')}"
end

distros = {
  "ubuntu" => { "1804" => [ "distro", "upstream" ], "2004" => [ "distro", "upstream" ] },
  "rhel" => { "7"  => [ "distro", "upstream" ], "8" => [ "upstream" ] },
  "centos" => { "7"  => [ "distro", "upstream" ], "8" => [ "upstream" ] },
  "arch" => { ""  => [ "distro" ] }
}
groups = {}

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

  distros.each_with_index do |(distro, versions)|
    groups["distro_" + distro] = []
    versions.each_with_index do |(version, dockers)|
      groups["release_" + distro + version] = []
      dockers.each do |(docker)|
        groups["docker_" + docker] = []
        hostname = distro + version + docker
        config.vm.define hostname do |cfg|
          cfg.vm.provider :virtualbox do |vb, override|
            config.vm.box = "generic/" + distro + version
            override.vm.hostname = hostname
            vb.name = hostname
            groups["distro_" + distro] << hostname
            groups["release_" + distro + version] ||= []
            groups["release_" + distro + version] << hostname
            groups["docker_" + docker] << hostname
            if distro == "rhel" or distro == "centos"
              groups["family_el" + version] ||= []
              groups["family_el" + version] << hostname
            end
            if distro == "arch"
              config.vm.provision "shell", inline: "[ -f /etc/arch-release ] && pacman -Sy --noconfirm python || true"
            end
          end
          # Copy in Ansible files.
          config.vm.provision "file", source: "playbook.yml", destination: "/home/vagrant/playbook.yml"
          config.vm.provision "file", source: "requirements.yml", destination: "/home/vagrant/requirements.yml"
          # Primary provisioning in Ansible.
          config.vm.provision "ansible_local" do |ansible|
            ansible.become = true
            ansible.provisioning_path = "/home/vagrant"
            ansible.playbook = "playbook.yml"
            ansible.install_mode = "pip"
            ansible.version = "2.9.9"
            ansible.galaxy_role_file = "requirements.yml"
            ansible.galaxy_roles_path = "/etc/ansible/roles"
            ansible.galaxy_command = "sudo ansible-galaxy install --role-file=%{role_file} --roles-path=%{roles_path} --force"
            ansible.groups = groups
            ansible.extra_vars = {
              redhat_username: ENV['REDHAT_USERNAME'],
              redhat_password: ENV['REDHAT_PASSWORD'],
            }
          end
        end
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
