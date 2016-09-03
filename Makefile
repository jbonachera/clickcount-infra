all: build run
build:
	packer-io build packer/nomad.json
run:
	cd terraform && terraform apply -state=state/terraform.tfstate
destroy:
	cd terraform && terraform destroy -force -state=state/terraform.tfstate
