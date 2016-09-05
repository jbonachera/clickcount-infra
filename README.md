# ClickCount infra
AWS project to run the ClickCount Application.

This is a sample implementation of an image-based infrastructure, using Packer (https://www.packer.io/), Terraform (https://www.terraform.io/), Ansible (https://www.ansible.com/) for image provisioning, running on Amazon Web Services.
Vagrant (https://www.vagrantup.com/) is also used for local testing.

The platform, once deployed, runs Docker applications using a combo of Nomad (https://www.nomadproject.io/), Consul (https://www.consul.io/) and Traefik (http://traefik.io/) for service exposition.

## Requirements

You SSH public key must be imported in AWS.

A DNS zone must be created in AWS.
Terraform could handle that, but NS servers of the zone change every time a zone is destroyed and created. 
I run this project under a sub-domain of another zone, and changing NS servers every cycle was too painful.

Don't forget to tweak SOA caching and negative-caching values before testing (waiting 1h for an NXDOMAIN to expire is annoying).

## Docker

A docker image with Terraform, Ansible and Packer can be build with `docker build -t builder .`.
Use this if you don't want to, or can't, install those tools on your computer.
It can be run with:
```
docker run --rm -it -v $(pwd)/terraform/state/:/usr/local/src/clickcount-infra/terraform/state/ builder
```

The Docker image accepts the same arguments as `make`: build, run and destroy.


All the environment variables described in Environment Setup below can be passed with -e, just strip the `TF_VAR_` part (`TF_VAR_zone` becomes juste `zone`):

```
docker build -t jbonachera/builder .
docker run --rm -it -e lb_auth_token=Password \ 
                    -e aws_access_key=<aws access key> \
                    -e aws_secret_key=<aws secret key> \
                    -e aws_region=eu-central-1 \
                    -e zone_id=<zone id> \
                    -e zone=cloud.example.net \
                    -e aws_ssh_key=<key name> \
                    -v $(pwd)/terraform/state/:/usr/local/src/clickcount-infra/terraform/state/ \
                    jbonachera/builder

```

If a variable is missing, you will be asked for the value.

## Building

### Environment setup

You will need to install at least Packer and Ansible on your host before you can build this project.

Building requires some environment variables:

  * TF_VAR_aws_access_key: AWS access key
  * TF_VAR_aws_secret_key: AWS secret key
  * TF_VAR_aws_region: AWS region
  * TF_VAR_aws_ssh_key: the SSH key name to inject into instances via cloud-init
  * TF_VAR_zone_id: AWS Route53 zone ID
  * TF_VAR_zone: AWS Route53 zone name
  * TF_VAR_lb_auth_token: the "token" to access nomad API (see below)

You can put them in a `credentials` file and source it before calling Packer or Terraform; git will auto-magically ignore it.

### AMI creation

You can build the project by running `make build` in the project folder.

Building this project runs the following tasks:
  
  * Spawns a base AMI on AWS
  * Configures it with Ansible, applying the "nomad" playbook
  * Shutdowns the instance, and create an AMI from it, named "nomad-host-{{timestamp}}".

All those steps are handled by Packer, using Ansible and AWS API under the hood.
Packer configuration is stored in packer/nomad.json.

## Running

Running the project requires Terraform to be installed, and the AMI created in the Build step to be accessible.

You can run the project by executing `make run` in the project folder.
It will:

  * Look for the most recent AMI named "nomad-host-*"
  * Spawn 3 instances using the AMI, and inject their IP addresses into consul and nomad configuration.
  * Create the required security groups, ELB and DNS records
  * Output the ELB DNS name and instances IP addresses on stdout

Those steps done, Nomad HTTP API will be accessible on `http://nomad.<your domain>:8080/` and applications on `http://<app-name>.app.<your domain/`.
Nomad API access requires you to include a `X-Auth-Token` header, with the value provided in the `TF_VAR_lb_auth_token` variable. It defaults to `Secret123`.

At first cluster boot, Cloud-init will execute a user-data script to inject instance IP address in consul and nomad configuration files.

Consul agents will find themselves using the `consul.discovery.<your dns zone>` DNS record, and they will form a Consul cluster. This is done by a script in `/usr/local/bin/bootstrap_consul.sh`.

Nomad will start, and a elect a Nomad cluster leader.
Then, nomad jobs described in ansible/roles/nomad/files/jobs/ will be created if they do not already exist. This is done by the `import_nomad_jobs` systemd unit, calling a python script.
This script will wait for the cluster to boot. After that, it will look for the cluster leader, and import the jobs if the current node is the cluster leader.
The script runs on all the nomad hosts at boot.

3 Jobs are shipped with the project:
  * clickcount: a sample Java application
  * clickcount-staging: the same application, but running from a different Docker tag.
  * nomadui: A fancy dashboard displaying the Nomad cluster state (Jobs, nodes, .. etc). See https://github.com/iverberk/nomad-ui for source.

## Destroying

You can destroy all the resources managed by Terraform by running `make destroy`.
It will not destroy the other resources (unless you messed up with the tfstate* files Terraform uses to manage it state), so it is quite safe.

## Development

You can use Vagrant to spawn a local Nomad cluster: `vagrant up`.
After editing Ansible roles, you can apply changes on the cluster with `vagrant provision`.

A few tests are present in tests/ folder, using Python testinfra. 
You can run them with

```
vagrant ssh-config > .vagrant/ssh-config
testinfra --hosts=default --ssh-config=.vagrant/ssh-config tests/nomad.py 
```

If you want to run the tests on a remote host, you can run:

```
testinfra -v  tests/nomad.py --connection=ssh --hosts=<host> --ssh-config=ssh_config
```

(The `ssh_config` file tells openssh client to ignore the remote host key verification. *Use only this for testing on ephemeral hosts* )

## TODO

  * Replace the X-Auth-Token with a Basic Authorization header, to allow using the command-line nomad client
  * Implement rolling replacement of Nomad hosts
  * Execute all actions from a CI tool, when a git event occurs
