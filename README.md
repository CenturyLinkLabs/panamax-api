![Master_Build_Status](https://circleci.com/gh/CenturyLinkLabs/panamax-api/tree/master.png?circle-token=efb1740d6408884a8e02518ad59b71bd4f81a627)

[![Coverage Status](https://coveralls.io/repos/CenturyLinkLabs/panamax-api/badge.png)](https://coveralls.io/r/CenturyLinkLabs/panamax-api)

The API behind [The Panamax UI](https://github.com/CenturyLinkLabs/panamax-ui).

## Getting Started

If you're trying to install panamax as a complete package: [Follow these instructions](http://panamax.io/get-panamax).

If you are a potential contributor or would like to install the API only, read on.

### Pre-requisites
* Install a Vagrant provider (VirtualBox or VMWare etc.)
* Install Vagrant

### Install the API
1.) create a directory named panamax and cd into it
```
mkdir panamax && cd panamax
```
2.) clone the repo
```
git clone git@github.com:CenturyLinkLabs/panamax-api.git
```
3.) Create a Vagrantfile
```
CLOUD_CONFIG_PATH = "./user-data"

Vagrant.configure("2") do |config|
  config.vm.box = "coreos-beta"
  config.vm.box_url = "http://beta.release.core-os.net/amd64-usr/current/coreos_production_vagrant.json"

  # replace the first argument with your path to panamax
  config.vm.synced_folder "/[path-to-panamax]/panamax/panamax-api", "/var/panamax-api", type: "rsync"
  config.vm.network :forwarded_port, guest: 80, host: 8888 # you can use whichever port you wish for host

  # Fix docker not being able to resolve private registry in VirtualBox
  config.vm.provider :virtualbox do |vb, override|
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
    vb.memory = 3000
  end
end
```
4.) run vagrant up and login
```
vagrant up && vagrant ssh
```
5.) Start etcd, fleet and journal-gatewayd services
```
sudo useradd --system systemd-journal-gateway # Add system account for journal gateway service
sudo systemctl start etcd
sudo systemctl start fleet
sudo systemctl start systemd-journal-gatewayd.socket
```
6.) download the dockerfile from: https://github.com/CenturyLinkLabs/panamax-ruby-base/tree/alpha, then build it
```
docker build -t panamax/ruby . #don't forget the trailing dot
```
7.) Run the image with the api code mounted
```
docker run -i -t -v /var/panamax-api:/var/app/panamax-api -v /var/run/docker.sock:/run/docker.sock -p 80:3000 -e "FLEETCTL_ENDPOINT=http://172.17.42.1:4001" panamax/ruby /bin/bash
```
8.) Install the api dependencies
```
# inside the running container
apt-get install libsqlite3-dev
cd /var/app/panamax-api
bundle
bundle exec rake db:create db:migrate db:seed
bundle exec rake panamax:templates:load
bundle exec rails server
```
9.) curl http://localhost:8888/apps
