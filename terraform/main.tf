provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.aws_region}"
}
resource "null_resource" "cluster" {
  depends_on = [
    "aws_instance.nomad",
    "aws_security_group_rule.allow_all_from_nomad",
    "aws_security_group_rule.allow_ssh",
    "aws_security_group_rule.allow_outbound"
  ]
  connection {
      host = "${aws_instance.nomad.0.public_ip}"
  }

  triggers {
    nomad_instance_ids = "${join(",", aws_instance.nomad.*.id)}"
  }

  provisioner "remote-exec" {
      inline = [
          "${formatlist("/usr/local/bin/consul join %s", aws_instance.nomad.*.private_ip)}"
      ]
  }
}
