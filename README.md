# Panamax: Docker Management for Humans

[Panamax](http://panamax.io) is a containerized app creator with an open-source app marketplace hosted in GitHub. Panamax provides a friendly interface for users of Docker, Fleet & CoreOS. With Panamax, you can easily create, share, and deploy any containerized app no matter how complex it might be. Learn more at [Panamax.io](http://panamax.io) or browse the [Panamax Wiki](https://github.com/CenturyLinkLabs/panamax-ui/wiki).

# Panamax API
![Master_Build_Status](https://circleci.com/gh/CenturyLinkLabs/panamax-api/tree/master.png?circle-token=efb1740d6408884a8e02518ad59b71bd4f81a627)

[![Coverage Status](https://coveralls.io/repos/CenturyLinkLabs/panamax-api/badge.png)](https://coveralls.io/r/CenturyLinkLabs/panamax-api)

The API behind [The Panamax UI](https://github.com/CenturyLinkLabs/panamax-ui).

The Panamax API interacts with a number of APIs running on the local system to launch and gather information about applications:

* [Docker Remote API](https://docs.docker.com/reference/api/docker_remote_api_v1.12/) - Get status information for running containers and search for images.
* [etcd API](https://coreos.com/docs/distributed-configuration/etcd-api/) - Send data to the CoreOS Fleet daemon.
* [systemd-journal-gatewayd.services](http://www.freedesktop.org/software/systemd/man/systemd-journal-gatewayd.service.html) - Retrieve journal output for running services.

Additional, external APIs are also used to do things like query the Docker Hub and collect usage metrics:

* [Docker Registry API](https://docs.docker.com/reference/api/registry_api/) - Retrieve tags for images in the Docker Registry.
* [GitHub API](https://developer.github.com/v3/) - Publish templates to GitHub repositories.
* [MailChimp API](http://apidocs.mailchimp.com/) - Allow users to subscribe to the CenturyLink Labs mailing list.
* [KissMetrics API](http://support.kissmetrics.com/apis/specifications.html) - Collect data about the templates users are running.

## Getting Started

If you're trying to install panamax as a complete package: [Follow these instructions](http://panamax.io/get-panamax).

If you are a potential contributor or would like to install the API only, read on.

### Pre-requisites
In its current form Panamax only works with CoreOS as the host system. The Panamax API application is meant to run inside a Docker container on a CoreOS host where it has visibility to the Docker, etcd, and systemd-journal-gatewayd APIs.

We recommend you use the [Running CoreOS on Vagrant](https://coreos.com/docs/running-coreos/platforms/vagrant/) instructions to get CoreOS running on your local system in VirtualBox. Make sure you have VirtualBox, Vagrant and the CoreOS *Vagrantfile* installed before proceeding.

### Check-out the Code
A typical development set-up for Panamax API will consist of your local machine (running whatever OS you choose), a VirtualBox VM running CoreOS and then a Docker container hosting the Panamax API application.

Ultimately, you need to get the *panamax-api* source code into the Docker container, and there are a number of ways to accomplish that:

* `git clone` the source code directly into the Docker container
* `git clone` the source code in the CoreOS host and then share it into the Docker container via volume mount
* `git clone` the source code on the local system, share it into CoreOS via rsync or NFS, and then share it from CoreOS to the Docker container via volume mount.

While the third option is the most complicated it does give you the flexibility to use your usual editor/IDE on your local system while running the application itself in the Docker container. This is the option that we'll walk-through below.

Start by cloning the *panamax-api* repository:

	git clone https://github.com/CenturyLinkLabs/panamax-api.git

### Start CoreOS

1) Update your *Vagrantfile* to share the *panamax-api* directory (the one cloned above) into the CoreOS VM. If you used the *Vagrantfile* provided in the CoreOS installation instructions you should find a sample `synced_folder` instruction that has been commented-out. Edit it to reflect the path to your *panamax-api* directory and un-comment it.

	config.vm.synced_folder "/Users/jdoe/panamax-api", "/home/core/panamax-api", 
	  id: "core", :nfs => true, :mount_options => ['nolock,vers=3,udp']

2) Open a port so that you can reach the Panamax API from your local machine. Place the following line in your *Vagrantfile* (you can choose whatever port numbers you like).

	config.vm.network :forwarded_port, guest: 8888, host: 8888
	
3) Start the CoreOS virtual machine. From the directory where your *Vagrantfile* is located do the following

	vagrant up && vagrant ssh
	

### Start the Container

At this point you should find yourself at the CoreOS prompt.

1) Start etcd, fleet and journal-gatewayd services. These three services are used by the Panamax API and need to be running in CoreOS.

	sudo systemctl start etcd
	sudo systemctl start fleet
	sudo systemctl start systemd-journal-gatewayd.socket

If you get tired of manually starting these services there are [instructions](https://coreos.com/docs/running-coreos/platforms/vagrant/#single-machine) in the CoreOS documentation for starting these services automatically via Cloud-Config.

2) Pull the base docker images for running the *panamax-api* container.

    docker pull centurylink/panamax-ruby-base
    
3) Start the container

	docker run -it \
	  -v /home/core/panamax-api:/var/app/panamax-api \
	  -v /run/docker.sock:/run/docker.sock \
	  -p 8888:3000 
	  -e "FLEETCTL_ENDPOINT=http://10.1.42.1:4001" 
	  -e "JOURNAL_ENDPOINT=http://10.1.42.1:19531" \
	  centurylink/panamax-ruby-base /bin/bash
	  
The first `-v` argument bind mounts the *panamax-api* source directory into the container. The container path you use for the volume mount can be anything you choose (it's */var/app/panamax-api* in the example above). Obviously, the host path must match the the directory in CoreOS where the code was shared.

The second `-v` argument bind mounts the Docker daemon's API socket into the container. This is how the Panamax API is able to interact with the Docker daemon from inside the container.

The `-p` argument creates a mapping between port 3000 in the container (the default port used by the Rails application) and port 8888 on CoreOS (note that host port here needs to match the guest port specified by the mapping in the *Vagrantfile*). This gives us a network path from the local machine, through CoreOS, to the application running inside the *panamax-api* container.

The two `-e` arguments are used to inject the endpoints for the Fleet and Journal APIs. The IP address used in these environment variables should match that of the *docker0* network interfact in CoreOS. You should be able to use the values shown above as-is, but we've seen a few occasions where the *docker0* interface is assigned a different address. You can check the address assigned to the *docker0* interface by running `ifconfig` at the CoreOS prompt.

### Start the Application

You should now be at a prompt inside the running container. 

1) Change to the directory containing the *panamax-api* source code

	cd /var/app/panamax-api

2) Install the application's gem dependencies
	
	bundle
	
3) Set-up the SQLite database and load the sample templates

	rake db:create db:migrate db:seed
	rake panamax:templates:load

4) Star the application

	rails server

If you used all the configuration values specified in these instructions, the Panamax API should now be accessible from your local machine on port 8888:

	$ curl http://localhost:8888/local_images.json
	
	[{"id":"8effcd007cad6bbdb936d547fac60f65c5f24f5a579e8d34e50e220d588dac70","virtual_size":436409804,"tags":["centurylink/panamax-ruby-base:latest"]}]
