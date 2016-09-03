job "clickcount" {
	datacenters = ["dc1"]
	constraint {
		attribute = "${attr.kernel.name}"
		value = "linux"
	}
	update {
		stagger = "10s"
		max_parallel = 1
	}
	group "clickcount" {
		restart {
			attempts = 10
			interval = "5m"
			
			delay = "25s"
			mode = "delay"
		}
		task "front" {
			driver = "docker"
			config {
				image = "jbonachera/clickcount:latest"
				port_map {
					web = 8080
				}
			}
                        env {
                            redis_host = "52.59.157.34"
                        }
			service {
				name = "${TASKGROUP}-front"
				tags = [
				"traefik.enable=true",
				"traefik.frontend.entryPoints=http",
				"traefik.frontend.rule=Host:clickcount.app.cloud.vx-labs.net"
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
                                memory = 200
				network {
					mbits = 10
					port "web" {
					}
				}
			}
			
			 
		}
	}
}

