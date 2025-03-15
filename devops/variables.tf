variable "root_path" {
  type = string
}

#-------------------------------
# PROVIDER: NOMAD
#-------------------------------

variable "provider_nomad_host" {
  type    = string
  default = "nomad.homeassistant.internal"
}

#-------------------------------
# PROVIDER: MINIO
#-------------------------------

variable "provider_minio_host" {
  type    = string
  default = "s3.homeassistant.internal"
}

variable "provider_minio_port" {
  type    = string
  default = "80"
}

variable "provider_minio_username" {
  type    = string
  default = "admin"
}

variable "provider_minio_password" {
  type    = string
  default = "changeme"
}

#-------------------------------
# PROVIDER: POSTGRES
#-------------------------------

variable "provider_postgres_host" {
  type    = string
  default = "rds-postgres.homeassistant.internal"
}

variable "provider_postgres_port" {
  type    = string
  default = "5432"
}

variable "provider_postgres_username" {
  type    = string
  default = "admin"
}

variable "provider_postgres_password" {
  type    = string
  default = "changeme"
}

variable "traefik_ip" {
  type    = string
  default = "10.1.0.2"
}