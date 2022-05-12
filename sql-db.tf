resource "random_string" "rand" {
  length  = 4
  upper   = false
  special = false
}

locals {
  instance_name    = "${var.name}-${random_string.rand.result}"
  database_version = "POSTGRES_${var.postgres_major_engine_version}"
  ip_configuration = {
    ipv4_enabled        = true
    require_ssl         = false
    private_network     = module.gcp-network.network_id
    allocated_ip_range  = null
    authorized_networks = var.authorized_networks
  }
  read_replicas = [
    for zone in var.zones: {
      name                = index(var.zones, zone)
      zone                = zone
      tier                = var.postgres_instance_tier
      ip_configuration    = local.ip_configuration
      database_flags      = [{ name = "autovacuum", value = "off" }]
      disk_autoresize     = null
      disk_size           = null
      disk_type           = "PD_HDD"
      user_labels         = local.labels
      encryption_key_name = null
    }
  ]
}

module "sql-db" {
  source               = "GoogleCloudPlatform/sql-db/google//modules/postgresql"
  name                 = local.instance_name
  db_name              = var.db_name
  user_name            = var.db_user
  database_version     = local.database_version
  random_instance_name = true
  project_id           = var.project
  zone                 = var.zones[0]
  region               = var.region
  tier                 = var.postgres_instance_tier
  user_labels          = local.labels

  deletion_protection = false

  ip_configuration = local.ip_configuration

  backup_configuration = {
    enabled                        = true
    start_time                     = "20:55"
    location                       = null
    point_in_time_recovery_enabled = false
    transaction_log_retention_days = null
    retained_backups               = 365
    retention_unit                 = "COUNT"
  }

  read_replica_name_suffix = "-ro-"
  read_replicas = local.read_replicas

  depends_on = [
    google_service_networking_connection.private_vpc_connection
  ]
}
