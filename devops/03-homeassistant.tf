resource "nomad_namespace" "homeassistant_system" {
  name = "homeassistant-system"

  depends_on = [
    null_resource.postgres,
  ]
}

resource "nomad_variable" "homeassistant_postgres_configuration" {
  path      = "monitoring/homeassistant/configuration/postgres"
  namespace = nomad_namespace.homeassistant_system.id
  items = {
    host     = "${var.provider_postgres_host}"
    port     = "${var.provider_postgres_port}"
    database = "homeassistant"
    username = "homeassistant"
    password = "${random_password.homeassistant_postgres.result}"
  }

  depends_on = [
    nomad_namespace.homeassistant_system,
  ]
}

resource "nomad_job" "homeassistant" {
  jobspec = templatefile("${path.module}/jobs/homeassistant.hcl", {
    destination              = "worker-homeassistant",
    homeassistant_docker_tag = "2025.3"
  })
  purge_on_destroy = true

  depends_on = [
    nomad_variable.homeassistant_postgres_configuration,
  ]
}

resource "null_resource" "homeassistant" {
  depends_on = [
    // parent
    null_resource.postgres,
    // resources
    nomad_namespace.homeassistant_system,
    nomad_variable.homeassistant_postgres_configuration,
    nomad_job.homeassistant,
  ]
}