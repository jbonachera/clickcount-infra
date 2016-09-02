output "ip" {
  value = "${join(", ",aws_instance.nomad.*.public_ip)}"
}

output "service lb name" {
  value = "${aws_elb.service_elb.dns_name}"
}

output "nomad lb name" {
  value = "${aws_elb.nomad_elb.dns_name}"
}

