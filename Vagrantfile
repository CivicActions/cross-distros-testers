boxes = [
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

Vagrant.configure("2") do |config|
  config.vm.provider "virtualbox" do |v|
    v.memory = 512
    v.cpus = 1
  end
  config.vm.boot_timeout = 600

  boxes.each do |(box)|
    config.vm.define box do |cfg|
      cfg.vm.box = box
      cfg.vm.box_url = "file://" + box + "/package.box"
      cfg.vm.provider "virtualbox" do |v|
        v.name = box
      end
    end
  end

  # Windows box based on: https://gitlab.com/gitlab-org/gitlab-runner/-/blob/master/Vagrantfile
end