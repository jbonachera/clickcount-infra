all: build run
build:
	packer-io build packer/nomad.json
run:
	cd terraform && terraform apply
destroy:
	cd terraform && terraform destroy -force
