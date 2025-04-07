job "epshome" {
  datacenters = ["europe-paris"]
  namespace   = "homeassistant-system"
  type        = "service"

  constraint {
    attribute = "$${attr.unique.hostname}"
    value     = "europe-paris-${destination}"
  }

  group "epshome" {
    count = 1

    network {
      mode = "host"
      port "epshome-http" {
        to = 6052
      }
    }

    task "epshome" {
      driver = "docker"
      user   = "root"

      config {
        image        = "ghcr.io/esphome/esphome:${epshome_docker_tag}"
        privileged   = true
        network_mode = "host"
        ports        = ["epshome-http"]
        volumes = [
          "/mnt/epshome_config_data:/config",
        ]
      }

      resources {
        cpu    = 500
        memory = 512
      }

      service {
        provider = "nomad"
        name     = "epshome-http"
        port     = "epshome-http"
        check {
          type     = "http"
          path     = "/"
          interval = "10s"
          timeout  = "2s"
        }
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.epshome.rule=Host(`epshome.homeassistant.internal`)",
          "traefik.http.routers.epshome.entrypoints=web",
          "traefik.http.services.epshome.loadbalancer.passhostheader=true",
        ]
      }

      logs {
        max_files     = 1
        max_file_size = 5
      }
    }
  }
}