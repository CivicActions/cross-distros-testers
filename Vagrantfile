# Distro, version, docker stream(s).
distros = {
  "ubuntu" => { "1804" => [ "distro", "upstream" ], "2004" => [ "distro", "upstream" ] },
  "rhel" => { "7"  => [ "distro", "upstream" ], "8" => [ "upstream" ] },
  "centos" => { "7"  => [ "distro", "upstream" ], "8" => [ "upstream" ] },
  "arch" => { ""  => [ "distro" ] }
}
groups = {}

Vagrant.configure("2") do |config|
  config.env.enable
  config.vm.provider "virtualbox" do |v|
    v.memory = 512
    v.cpus = 1
  end

  distros.each_with_index do |(distro, versions)|
    groups["distro-" + distro] = []
    versions.each_with_index do |(version, dockers)|
      groups["release-" + distro + version] = []
      dockers.each do |(docker)|
        groups["docker-" + docker] = []
        hostname = distro + version + docker
        config.vm.define hostname do |cfg|
          cfg.vm.provider :virtualbox do |vb, override|
            config.vm.box = "generic/" + distro + version
            override.vm.hostname = hostname
            vb.name = hostname
            groups["distro-" + distro] << hostname
            groups["release-" + distro + version] ||= []
            groups["release-" + distro + version] << hostname
            groups["docker-" + docker] << hostname
            if distro == "rhel" or distro == "centos"
              groups["family-el" + version] ||= []
              groups["family-el" + version] << hostname
            end
          end
        end
      end
    end
  end

  # Install Python on Arch so Ansible can bootstrap.
  # We can't easily provision commands on specific distros here, so we do a check inline.
  config.vm.provision "shell", inline: "[ -f /etc/arch-release ] && pacman -Sy --noconfirm python || true"
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
