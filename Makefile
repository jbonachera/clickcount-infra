all: build run
build:
	packer-io build nomad.packer.json
run:
	cd terraform && terraform apply
destroy:
	cd terraform && terraform destroy -force
