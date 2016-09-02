data_dir = "/var/lib/nomad"
datacenter = "dc1"

client {
  enabled = true
  network_speed = 800
}
consul {
    auto_advertise = true
    server_auto_join = true
    client_auto_join = true
}

server {
  enabled = true
  bootstrap_expect = 2
}
