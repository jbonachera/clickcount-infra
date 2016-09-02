resource "aws_security_group" "nomad" {
    name = "nomad secgroup"
}

resource "aws_security_group_rule" "allow_all_from_nomad" {
    type = "ingress"
    from_port = 0
    to_port = 65535
    protocol = "-1"
    security_group_id = "${aws_security_group.nomad.id}"
    cidr_blocks = ["${split(",", join(",", formatlist("%s/32", aws_instance.nomad.*.private_ip)))}"]
}

resource "aws_security_group_rule" "allow_http" {
    type = "ingress"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_group_id = "${aws_security_group.nomad.id}"
    cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_ssh" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    security_group_id = "${aws_security_group.nomad.id}"
    cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_8080" {
    type = "ingress"
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    security_group_id = "${aws_security_group.nomad.id}"
    cidr_blocks = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "allow_outbound" {
    type = "egress"
    from_port = 0
    to_port = 65535
    protocol = "-1"
    security_group_id = "${aws_security_group.nomad.id}"
    cidr_blocks = ["0.0.0.0/0"]
}

