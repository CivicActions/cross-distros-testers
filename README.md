# Cross Distro Testing

This uses Vagrant, VirtualBox and Ansible to provision a series of virtual machines running different GNU/Linux distributions, with Docker and Gitlab Runner installed on each.

- This uses a matrix to test different distro versions, as well as testing with both the distro provided Docker package and the upstream docker.com package.
- This is ideal for testing Docker applications using the [Gitlab Runner VirtualBox executor](https://docs.gitlab.com/runner/executors/virtualbox.html) but could also be used in other test situations.
- The design is fairly simplistic and not currently intended for extensibility. It should be easy enough to adapt as a template however.
- This includes RedHat Enterprise Linux tests - you will need a username and password with access to licenses.

## Getting started

- Install Vagrant and VirtualBox (you don't need Ansible installed locally as it runs on the VMs)
- Clone this repository to a working directory
- In the working directory run:

```
vagrant plugin install vagrant-env
echo 'REDHAT_USERNAME=<redhat-username-here>' > .env
echo 'export REDHAT_PASSWORD=<redhat-password-here>' >> .env
vagrant up
```

- If you are using the [Gitlab Runner VirtualBox executor](https://docs.gitlab.com/runner/executors/virtualbox.html) you will then need to:
  - Stop the VMs using `vagrant halt`
  - Install Gitlab Runner on the host
  - Follow the [directions](https://docs.gitlab.com/runner/executors/virtualbox.html) to register the runner with your Gitlab instance
