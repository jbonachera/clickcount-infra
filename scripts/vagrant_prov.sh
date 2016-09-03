#/bin/bash
# Quickly bootstrap the cluster.

cat > /etc/nomad/addresses.hcl <<EOF
bind_addr= "0.0.0.0"
advertise {
  http = "$(ip -f inet -o a show dev enp0s8 | awk '{print $4; exit}' | cut -d / -f 1):4646"
  rpc = "$(ip -f inet -o a show dev enp0s8 | awk '{print $4;  exit}' | cut -d / -f 1):4647"
  serf = "$(ip -f inet -o a show dev enp0s8 | awk '{print $4; exit}' | cut -d / -f 1):4648"
}
EOF
cat > /etc/consul/addresses.json <<EOF
{
  "bind_addr": "0.0.0.0",
  "advertise_addr": "$(ip -f inet -o a show dev enp0s8 | awk '{print $4; exit}' | cut -d / -f 1)"
}
EOF
chown consul: /etc/consul/addresses.json
cat >> /etc/traefik/traefik.toml << EOF                                                                                                                                                                
[file]
[frontends]
  [frontends.nomad-http]
  backend = "local-nomad"
  entrypoints = ["admin"]
    [frontends.nomad-http.routes.auth]
    rule = "Headers:X-Auth-Token, Secret123"
[backends]
  [backends.local-nomad]
    [backends.local-nomad.servers.localhost]
    url = "http://localhost:4646/"
    weight = 10
EOF
systemctl restart docker
systemctl restart traefik
systemctl restart consul
systemctl restart nomad
