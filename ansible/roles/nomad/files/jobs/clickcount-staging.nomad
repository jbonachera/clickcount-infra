job "clickcount-staging" {
	datacenters = ["dc1"]
	constraint {
		attribute = "${attr.kernel.name}"
		value = "linux"
	}
	update {
		stagger = "10s"
		max_parallel = 1
	}
	group "clickcount-staging" {
		restart {
			attempts = 10
			interval = "5m"
			
			delay = "25s"
			mode = "delay"
		}
		task "front" {
			driver = "docker"
			config {
				image = "jbonachera/clickcount:dev"
				port_map {
					web = 8080
				}
			}
                        env {
                            redis_host = "52.29.47.216"
                        }
			service {
				name = "${TASKGROUP}-front"
				tags = [
				"traefik.enable=true",
				"traefik.frontend.entryPoints=http",
				"traefik.frontend.rule=Host:clickcount-staging.app.cloud.vx-labs.net"
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

