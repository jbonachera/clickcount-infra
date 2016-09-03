job "nomadui" {
	datacenters = ["dc1"]
	constraint {
		attribute = "${attr.kernel.name}"
		value = "linux"
	}
	update {
		stagger = "10s"
		max_parallel = 1
	}
	group "app" {
		restart {
			attempts = 10
			interval = "5m"
			
			delay = "25s"
			mode = "delay"
		}
		task "front" {
			driver = "docker"
			config {
				image = "iverberk/nomad-ui:0.1.0"
				port_map {
					web = 3000
				}
			}
                        env {
                            NOMAD_ADDR="172.17.0.1"
                        }
			service {
				name = "${TASKGROUP}-front"
				tags = [
                                   "traefik.enable=true",
                                   "traefik.frontend.entryPoints=http",
                                   "traefik.frontend.rule=Host:nomadui.app.cloud.vx-labs.net"
                                ]
				port = "web"
				check {
					name = "alive"
					type = "http"
                    path = "/"
					port = "web"
					interval = "10s"
					timeout = "2s"
				}
			}
			resources {
                memory = 100
				network {
					mbits = 10
					port "web" {
					}
				}
			}
			
			 
		}
	}
}

