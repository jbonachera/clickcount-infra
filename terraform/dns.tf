resource "aws_route53_record" "nomad" {
    zone_id = "${var.zone_id}"
    name = "${var.nomad_cname}"
    type = "A"
    alias {
      name = "${aws_elb.nomad_elb.dns_name}"
      zone_id = "${aws_elb.nomad_elb.zone_id}"
      evaluate_target_health = true
    }
}

resource "aws_route53_record" "service" {
    zone_id = "${var.zone_id}"
    name = "${var.service_cname}"
    type = "A"
    alias {
      name = "${aws_elb.service_elb.dns_name}"
      zone_id = "${aws_elb.service_elb.zone_id}"
      evaluate_target_health = true
    }
}

resource "aws_route53_record" "consul" {
    zone_id = "${var.zone_id}"
    name = "consul.discovery"
    type = "A"
    ttl = "10"
    records = ["${aws_instance.nomad.*.private_ip}"]
}
