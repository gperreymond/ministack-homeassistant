resource "nomad_namespace" "monitoring_system" {
  name = "monitoring-system"

  depends_on = [
    null_resource.homeassistant,
  ]
}

resource "nomad_variable" "thanos_store_configuration" {
  path      = "monitoring/thanos-store/configuration/bucket"
  namespace = nomad_namespace.monitoring_system.id
  items = {
    bucket     = minio_s3_bucket.thanos_stone.bucket
    endpoint   = var.provider_minio_host
    access_key = minio_iam_service_account.thanos_stone.access_key
    secret_key = minio_iam_service_account.thanos_stone.secret_key
  }

  depends_on = [
    nomad_namespace.monitoring_system,
  ]
}

resource "nomad_job" "prometheus" {
  jobspec = templatefile("${path.module}/jobs/prometheus.hcl", {
    destination           = "worker-monitoring",
    prometheus_docker_tag = "v3.2.1"
    thanos_docker_tag     = "v0.37.2"
  })
  purge_on_destroy = true

  depends_on = [
    nomad_variable.thanos_store_configuration,
  ]
}


resource "null_resource" "monitoring" {
  depends_on = [
    // parent
    null_resource.homeassistant,
    // resources: monitoring
    nomad_namespace.monitoring_system,
    nomad_variable.thanos_store_configuration,
    nomad_job.prometheus,
  ]
}
