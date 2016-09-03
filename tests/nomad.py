def test_nomad_running_and_enabled(Service):
    nomad = Service("nomad")
    assert nomad.is_running
    assert nomad.is_enabled

def test_consul_running_and_enabled(Service):
    consul = Service("consul")
    assert consul.is_running
    assert consul.is_enabled

def test_docker_running_and_enabled(Service):
    docker = Service("docker")
    assert docker.is_running
    assert docker.is_enabled

def test_traefik_running_and_enabled(Service):
    traefik = Service("traefik")
    assert traefik.is_running
    assert traefik.is_enabled

def test_traefik_listening(Socket):
    http = Socket("tcp://:::80")
    assert http.is_listening

