resource "aws_instance" "nomad" {
  count = "${var.nomad_instance_count}"
  ami           = "${data.aws_ami.nomad.id}"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.nomad.name}"]
  key_name = "${var.aws_ssh_key}"
  user_data = <<CMD
#!/bin/bash
cat > /etc/nomad/addresses.hcl <<EOF
bind_addr= "0.0.0.0"
advertise {
  http = "$(ip -f inet -o a show dev eth0 | awk '{print $4; exit}' | cut -d / -f 1):4646"
  rpc = "$(ip -f inet -o a show dev eth0 | awk '{print $4; exit}' | cut -d / -f 1):4647"
  serf = "$(ip -f inet -o a show dev eth0 | awk '{print $4; exit}' | cut -d / -f 1):4648"
}
EOF
cat > /etc/consul/addresses.json <<EOF
{
  "bind_addr": "0.0.0.0",
  "advertise_addr": "$(ip -f inet -o a show dev eth0 | awk '{print $4; exit}' | cut -d / -f 1)"
}
EOF
chown consul: /etc/consul/addresses.json
echo '
[file]
[frontends]
  [frontends.nomad-http]
  backend = "local-nomad"
  entrypoints = ["admin"]
    [frontends.nomad-http.routes.auth]
    rule = "Headers:X-Auth-Token, ${var.lb_auth_token}"
[backends]
  [backends.local-nomad]
    [backends.local-nomad.servers.localhost]
    url = "http://localhost:4646/"
    weight = 10
' | tee -a /etc/traefik/traefik.toml
systemctl restart traefik
systemctl restart consul
systemctl restart nomad
mkdir /etc/sysconfig/
echo DISCOVERY_DOMAIN=consul.discovery.${var.zone} > /etc/sysconfig/consul-bootstrap
systemctl start bootstrap_consul
CMD
}

