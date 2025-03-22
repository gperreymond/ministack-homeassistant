// --------------------------------------------------------
// HOME ASSISTANT
// --------------------------------------------------------

resource "random_password" "homeassistant_postgres" {
  length  = 32
  special = false

  depends_on = [
    null_resource.minio,
  ]
}

resource "postgresql_role" "homeassistant_postgres" {
  name     = "homeassistant"
  login    = true
  password = random_password.homeassistant_postgres.result

  depends_on = [
    random_password.homeassistant_postgres,
  ]
}

resource "postgresql_database" "homeassistant_postgres" {
  name  = "homeassistant"
  owner = postgresql_role.homeassistant_postgres.name

  depends_on = [
    postgresql_role.homeassistant_postgres,
  ]
}

// --------------------------------------------------------
// GRAFANA
// --------------------------------------------------------

resource "random_password" "grafana_postgres" {
  length  = 32
  special = false

  depends_on = [
    null_resource.minio,
  ]
}

resource "postgresql_role" "grafana_postgres" {
  name     = "grafana"
  login    = true
  password = random_password.grafana_postgres.result

  depends_on = [
    random_password.grafana_postgres,
  ]
}

resource "postgresql_database" "grafana_postgres" {
  name  = "grafana"
  owner = postgresql_role.grafana_postgres.name

  depends_on = [
    postgresql_role.grafana_postgres,
  ]
}

resource "null_resource" "postgres" {
  depends_on = [
    // parent
    null_resource.minio,
    // resources
    random_password.homeassistant_postgres,
    postgresql_role.homeassistant_postgres,
    postgresql_database.homeassistant_postgres,
    random_password.grafana_postgres,
    postgresql_role.grafana_postgres,
    postgresql_database.grafana_postgres,
  ]
}
