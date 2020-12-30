# -*- mode: ruby -*-
# vi: set ft=ruby :

distros = {
  "ubuntu" => { "1804" => [ "distro", "upstream" ], "2004" => [ "distro", "upstream" ] },
  "rhel" => { "7"  => [ "distro", "upstream" ], "8" => [ "distro", "upstream" ] },
  "centos" => { "7"  => [ "distro", "upstream" ], "8" => [ "distro", "upstream" ] },
  "arch" => { ""  => [ "distro" ] }
}

def get_windows_vm_box_version()
  # We're pinning to this specific version due to recent Docker versions (above 19.03.05) being broken
  # (see https://gitlab.com/gitlab-org/gitlab-runner/-/issues/27115)
  '2020.04.15'
end

Vagrant.configure("2") do |config|
  # config.vagrant.plugins = ["vagrant-env", "vagrant-reload", "winrm", "winrm-fs", "winrm-elevated"]
  config.vagrant.sensitive = [ENV["REDHAT_USERNAME"], ENV['REDHAT_PASSWORD']]
  config.vm.provider "virtualbox" do |v|
    v.memory = 512
    v.cpus = 1
    v.gui = false
    v.linked_clone = true
  end
  config.vm.boot_timeout = 600

  distros.each_with_index do |(distro, versions)|
    versions.each_with_index do |(version, dockers)|
      dockers.each do |(docker)|
        hostname = distro + version + docker
        config.vm.define hostname do |cfg|
          cfg.vm.box = "generic/" + distro + version
          cfg.vm.provider :virtualbox do |vb, override|
            override.vm.hostname = hostname
            vb.name = hostname
          end
          # Upgrade all packages and install base packages:
          if distro == "arch"
            cfg.vm.provision "shell", inline: "sudo pacman -Syuu --noconfirm"
            cfg.vm.provision "shell", inline: "sudo pacman -Sy --noconfirm bash zsh mksh git"
          end
          if distro == "rhel"
            cfg.vm.provision "shell", inline: "sudo subscription-manager register --force --username '" + ENV['REDHAT_USERNAME'] + "' --password '" + ENV['REDHAT_PASSWORD'] + "' --auto-attach"
            if version == "7"
              cfg.vm.provision "shell", inline: "sudo subscription-manager repos --enable rhel-7-server-extras-rpms"
            end
          end
          if distro == "rhel" || distro == "centos"
            cfg.vm.provision "shell", inline: "sudo yum -y update"
            cfg.vm.provision "shell", inline: "sudo yum -y install bash zsh mksh git"
          end
          if distro == "ubuntu"
            cfg.vm.provision "shell", inline: "sudo apt-get -y upgrade"
            cfg.vm.provision "shell", inline: "sudo apt-get -y install bash zsh mksh git"
          end
          # Then restart (needed in case of Kernel upgrades)
          cfg.vm.provision :reload
          # Docker setup:
          docker_service = true
          if docker == "distro"
             # Install distro docker:
            if distro == "arch"
              cfg.vm.provision "shell", inline: "sudo pacman -Sy --noconfirm docker"
            end
            if distro == "rhel" || distro == "centos"
              if version == "7"
                cfg.vm.provision "shell", inline: "sudo yum install -y docker"
              else
                # Podman instead
                docker_service = false
                cfg.vm.provision "shell", inline: "sudo dnf install -y podman slirp4netns"
                if distro == "rhel"
                  cfg.vm.provision "shell", inline: "sudo dnf module install -y container-tools"
                end
                # Add Docker alias
                cfg.vm.provision "shell", inline: 'echo "alias docker=\'podman\'" >> /etc/bash.bashrc'
                # Setup rootless access: https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/building_running_and_managing_containers/starting-with-containers_building-running-and-managing-containers
                cfg.vm.provision "shell", inline: 'echo "user.max_user_namespaces=28633" > /etc/sysctl.d/userns.conf'
                cfg.vm.provision "shell", inline: "sysctl -p /etc/sysctl.d/userns.conf"
                cfg.vm.provision "shell", inline: 'echo "vagrant:165537:65536" >> /etc/subuid'
                cfg.vm.provision "shell", inline: 'echo "vagrant:165537:65536" >> /etc/subgid'
              end
            end
            if distro == "ubuntu"
              cfg.vm.provision "shell", inline: "sudo apt-get install -y docker.io"
            end
          else
            # Install upstream docker:
            if distro == "rhel"
              # Use repo directly for RHEL as the script doesn't work
              cfg.vm.provision "shell", inline: "sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo"
              if version == "7"
                # The baseurl in the repo is broken for RHEL 7: 
                cfg.vm.provision "shell", inline: "sudo yum-config-manager --setopt='docker-ce-stable.baseurl=https://download.docker.com/linux/centos/7/x86_64/stable' --save"
              end
              cfg.vm.provision "shell", inline: "sudo yum install -y docker-ce"
            else
              cfg.vm.provision "shell", inline: "curl -fsSL https://get.docker.com | sh"
            end
          end
          # Ensure service started and vagrant user has access:
          if docker_service == true
            cfg.vm.provision "shell", inline: "sudo systemctl start docker"
            cfg.vm.provision "shell", inline: "sudo systemctl enable docker"
            cfg.vm.provision "shell", inline: "getent group docker || sudo groupadd docker"
            cfg.vm.provision "shell", inline: "sudo usermod -aG docker vagrant"
          end
          # Install Gitlab Runner:
          cfg.vm.provision "shell", inline: "sudo curl --silent --show-error -L --max-redirs 3 --retry 3 --retry-delay 2 --max-time 30 --output /usr/bin/gitlab-runner 'https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-amd64'"
          cfg.vm.provision "shell", inline: "sudo chmod +x /usr/bin/gitlab-runner"
          cfg.vm.provision "shell", inline: "sudo gitlab-runner install --user=vagrant --working-directory=/home/vagrant"
          cfg.vm.provision "shell", inline: "sudo gitlab-runner start"
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
      v.memory = '2048'
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
      v.memory = '2048'
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
