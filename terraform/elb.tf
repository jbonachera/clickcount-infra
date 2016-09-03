resource "aws_elb" "service_elb" {
  name = "service-elb"
  availability_zones = ["eu-central-1b"]
  security_groups = ["${aws_security_group.nomad.id}"]

  listener {
    # We us TCP here to allow websocket connexions
    instance_port = 80
    instance_protocol = "tcp"
    lb_port = 80
    lb_protocol = "tcp"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "TCP:8080"
    interval = 30
  }

  instances = ["${split(",", join(",", aws_instance.nomad.*.id))}"]
  idle_timeout = 400
  connection_draining = true
  connection_draining_timeout = 400

}
resource "aws_elb" "nomad_elb" {
  name = "nomad-elb"
  availability_zones = ["eu-central-1b"]
  security_groups = ["${aws_security_group.nomad.id}"]

  listener {
    instance_port = 8080
    instance_protocol = "http"
    lb_port = 8080
    lb_protocol = "http"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "TCP:8080"
    interval = 30
  }

  instances = ["${split(",", join(",", aws_instance.nomad.*.id))}"]
  idle_timeout = 400
  connection_draining = true
  connection_draining_timeout = 400

}
