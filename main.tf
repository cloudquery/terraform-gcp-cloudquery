
# google_client_config and kubernetes provider must be explicitly specified like the following.
# A lot is taken from the following example:
# https://github.com/terraform-google-modules/terraform-google-kubernetes-engine/blob/master/examples/simple_autopilot_public/main.tf

locals {
  network_name           = "${var.name}-network"
  subnet_name            = "${var.name}-subnet"
  master_auth_subnetwork = "${var.name}-public-master-subnet"
  pods_range_name        = "${var.name}-ip-range-pods-public"
  svc_range_name         = "${var.name}-ip-range-svc-public"
  subnet_names           = [for subnet_self_link in module.gcp_network.subnets_self_links : split("/", subnet_self_link)[length(split("/", subnet_self_link)) - 1]]
  zones                  = length(var.zones) > 0 ? var.zones : [data.google_compute_zones.available.names[0]]
}

# data "google_client_config" "default" {}

resource "random_password" "sql" {
  length  = 14
  special = false
}


resource "random_string" "pg_suffix" {
  length  = 4
  special = false
  upper   = false
}

# Services
module "project_services" {
  source = "terraform-google-modules/project-factory/google//modules/project_services"
  # version = "~> 13.0"

  project_id                  = var.project_id
  disable_services_on_destroy = false

  activate_apis = [
    "compute.googleapis.com",
    "container.googleapis.com",
    "servicenetworking.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "secretmanager.googleapis.com",
    "sts.googleapis.com"
  ]
}

module "gcp_network" {
  source  = "terraform-google-modules/network/google"
  version = "~> 5.0"

  project_id   = var.project_id
  network_name = local.network_name

  subnets = [
    {
      subnet_name   = local.subnet_name
      subnet_ip     = "10.0.0.0/17"
      subnet_region = var.region
    },
    {
      subnet_name   = local.master_auth_subnetwork
      subnet_ip     = "10.60.0.0/17"
      subnet_region = var.region
    },
  ]

  secondary_ranges = {
    (local.subnet_name) = [
      {
        range_name    = local.pods_range_name
        ip_cidr_range = "192.168.0.0/18"
      },
      {
        range_name    = local.svc_range_name
        ip_cidr_range = "192.168.64.0/18"
      },
    ]
  }

  depends_on = [
    module.project_services
  ]
}


# GKE Cluster
module "gke" {
  source  = "terraform-google-modules/kubernetes-engine/google//modules/beta-public-cluster"
  version = "~> 21.0"

  # Create an implicit dependency on service activation
  project_id = var.project_id

  name               = var.name
  region             = var.region
  regional           = false
  zones              = local.zones
  kubernetes_version = var.gke_version

  network           = module.gcp_network.network_name
  subnetwork        = local.subnet_names[index(module.gcp_network.subnets_names, local.subnet_name)]
  ip_range_pods     = local.pods_range_name
  ip_range_services = local.svc_range_name

  issue_client_certificate = true

  release_channel                 = "REGULAR"
  create_service_account          = true
  enable_vertical_pod_autoscaling = true

  node_pools = [
    {
      name         = "pool-01"
      machine_type = var.machine_type
      min_count    = 1
      max_count    = 2
      preemptible  = true
      disk_size_gb = 50
      # service_account = var.compute_engine_service_account
      auto_upgrade = true
    }
  ]
  depends_on = [
    module.project_services
  ]
}


resource "google_secret_manager_secret" "cloudquery" {
  secret_id = "${var.name}-secret"
  project   = var.project_id

  replication {
    automatic = true
  }
  depends_on = [
    module.project_services
  ]
}

resource "google_secret_manager_secret_version" "cloudquery" {
  secret = google_secret_manager_secret.cloudquery.id

  secret_data = "postgres://cloudquery:${random_password.sql.result}@${module.postgresql.private_ip_address}:5432/postgres"
}

data "google_secret_manager_secret_version" "cloudquery" {
  secret = google_secret_manager_secret.cloudquery.id
  depends_on = [
    google_secret_manager_secret_version.cloudquery
  ]
}



module "private_service_access" {
  source      = "GoogleCloudPlatform/sql-db/google//modules/private_service_access"
  project_id  = var.project_id
  vpc_network = module.gcp_network.network_name
  depends_on  = [module.gcp_network, module.project_services]
}

data "google_compute_zones" "available" {
  project = var.project_id
  region  = var.region
  depends_on = [
    module.project_services,
  ]
}

module "postgresql" {
  source           = "GoogleCloudPlatform/sql-db/google//modules/postgresql"
  name             = "${var.name}-${random_string.pg_suffix.result}"
  database_version = "POSTGRES_14"
  project_id       = var.project_id
  zone             = "${var.region}-c"
  region           = var.region
  tier             = "db-custom-1-3840"

  deletion_protection = false
  user_name           = "cloudquery"
  user_password       = random_password.sql.result

  ip_configuration = {
    ipv4_enabled        = true
    private_network     = module.gcp_network.network_self_link
    require_ssl         = false
    authorized_networks = var.authorized_networks
    allocated_ip_range  = module.private_service_access.google_compute_global_address_name
  }
  depends_on = [
    module.gcp_network,
    module.private_service_access,
    module.project_services
  ]
}


# allow list and read
data "google_service_account" "gke_sa" {
  account_id = module.gke.service_account
}

resource "google_project_iam_binding" "project" {
  project = var.project_id
  role    = "roles/viewer"

  members = [
    "serviceAccount:${module.gke.service_account}",
  ]

  depends_on = [
    helm_release.cloudquery,
    data.google_service_account.gke_sa,
    module.project_services
  ]
}

resource "google_service_account_iam_binding" "workload_identity_user" {
  service_account_id = data.google_service_account.gke_sa.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${var.project_id}.svc.id.goog[cloudquery/${var.name}]",
  ]
}
