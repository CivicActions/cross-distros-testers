variable "redhat_username" {
  type = string
}

variable "redhat_password" {
  type = string
}

source "vagrant" "defaults" {
  add_force    = true
  communicator = "ssh"
  provider     = "virtualbox"
  # skip_add     = true
  # skip_package = true
}

build {
  source "vagrant.defaults" {
    source_path = "generic/ubuntu1804"
    name        = "ubuntu_1804_distro"
  }
  source "vagrant.defaults" {
    source_path = "generic/ubuntu1804"
    name        = "ubuntu_1804_upstream"
  }
  source "vagrant.defaults" {
    source_path = "generic/ubuntu2004"
    name        = "ubuntu_2004_distro"
  }
  source "vagrant.defaults" {
    source_path = "generic/ubuntu2004"
    name        = "ubuntu_2004_upstream"
  }
  source "vagrant.defaults" {
    source_path = "generic/rhel7"
    name        = "rhel_7_distro"
  }
  source "vagrant.defaults" {
    source_path = "generic/rhel7"
    name        = "rhel_7_upstream"
  }
  source "vagrant.defaults" {
    source_path = "generic/rhel8"
    name        = "rhel_8_upstream"
  }
  source "vagrant.defaults" {
    source_path = "generic/centos7"
    name        = "centos_7_distro"
  }
  source "vagrant.defaults" {
    source_path = "generic/centos7"
    name        = "centos_7_upstream"
  }
  source "vagrant.defaults" {
    source_path = "generic/centos8"
    name        = "centos_8_upstream"
  }
  source "vagrant.defaults" {
    source_path = "generic/arch"
    name        = "arch_0_distro"
  }
  provisioner "shell" {
    only = ["vagrant.ubuntu_1804_distro", "vagrant.ubuntu_1804_upstream"]
    inline = [
      "DEBIAN_FRONTEND=noninteractive sudo apt-get --yes update",
      "DEBIAN_FRONTEND=noninteractive sudo apt-get --yes install software-properties-common",
      "DEBIAN_FRONTEND=noninteractive sudo apt-add-repository --yes --update ppa:ansible/ansible",
    ]
  }
  provisioner "shell" {
    only = ["vagrant.ubuntu_1804_distro", "vagrant.ubuntu_1804_upstream", "vagrant.ubuntu_2004_distro", "vagrant.ubuntu_2004_upstream"]
    inline = [
      "DEBIAN_FRONTEND=noninteractive sudo apt-get --yes update",
      "DEBIAN_FRONTEND=noninteractive sudo apt-get --yes install ansible"
    ]
  }
  provisioner "shell" {
    only = ["vagrant.rhel_7_distro", "vagrant.rhel_7_upstream", "vagrant.rhel_8_upstream"]
    inline = [
      "sudo subscription-manager register --username '${var.redhat_username}' --password '${var.redhat_password}' --auto-attach"
    ]
  }
  provisioner "shell" {
    only = ["vagrant.rhel_7_distro", "vagrant.rhel_7_upstream", "vagrant.centos_7_distro", "vagrant.centos_7_upstream", "vagrant.rhel_8_upstream", "vagrant.centos_8_upstream"]
    inline = [
      "sudo yum -y install ansible"
    ]
  }
  provisioner "shell" {
    only = ["vagrant.arch_0_distro"]
    inline = [
      "pacman -S ansible"
    ]
  }
  provisioner "ansible-local" {
    playbook_file = "playbook.yml"
    galaxy_file   = "requirements.yml"
    # Inject groups for the distro version, distro and docker source, used by ansible.
    inventory_groups = [
      "distro_version_${regex_replace(source.name, "_.*$", "")}",
      "distro_${regex_replace(source.name, "_[^_]+_[^_]+$", "")}",
      "docker_${regex_replace(source.name, "^[^_]+_[^_]+_", "")}"
    ]
  }
}
#ubuntu1804distro
#ubuntu1804upstream
#ubuntu2004distro
#ubuntu2004upstream
#rhel7distro
#rhel7upstream
#rhel8upstream
#centos7distro
#centos7upstream
#centos8upstream
#archdistro
