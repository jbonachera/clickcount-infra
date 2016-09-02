resource "aws_instance" "nomad" {
  count = 3
  ami           = "${data.aws_ami.nomad.id}"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.nomad.name}"]
  key_name = "jubon"
  provisioner "remote-exec" {
    inline = <<CMD
cat > /etc/nomad/addresses.hcl <<EOF
bind_addr= "0.0.0.0"
advertise {
  http = "${self.private_ip}:4646"
  rpc = "${self.private_ip}:4647"
  serf = "${self.private_ip}:4648"
}
EOF
cat > /etc/consul/addresses.json <<EOF
{
  "bind_addr": "0.0.0.0",
  "advertise_addr": "${self.private_ip}"
}
EOF
cat >> /etc/traefik/traefik.toml << EOF
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
EOF
systemctl restart traefik
systemctl restart consul
systemctl restart nomad
CMD
  }
}

