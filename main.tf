
# google_client_config and kubernetes provider must be explicitly specified like the following.
# Alot is taken from this example:
# https://github.com/terraform-google-modules/terraform-google-kubernetes-engine/blob/master/examples/simple_autopilot_public/main.tf

locals {
  network_name           = "${var.name}-network"
  subnet_name            = "${var.name}-subnet"
  master_auth_subnetwork = "${var.name}-public-master-subnet"
  pods_range_name        = "${var.name}-ip-range-pods-public"
  svc_range_name         = "${var.name}-ip-range-svc-public"
  subnet_names           = [for subnet_self_link in module.gcp_network.subnets_self_links : split("/", subnet_self_link)[length(split("/", subnet_self_link)) - 1]]
}

data "google_client_config" "default" {}

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
    "cloudresourcemanager.googleapis.com"
  ]
}

module "gcp_network" {
  source  = "terraform-google-modules/network/google"
  version = "~> 4.0"

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
}


# GKE Cluster
module "gke" {
  source  = "terraform-google-modules/kubernetes-engine/google//modules/beta-autopilot-public-cluster"
  version = "~> 20.0"

  # Create an implicit dependency on service activation
  project_id = var.project_id

  name               = var.name
  region             = var.region
  regional           = true
  kubernetes_version = var.gke_version

  network           = module.gcp_network.network_name
  subnetwork        = local.subnet_names[index(module.gcp_network.subnets_names, local.subnet_name)]
  ip_range_pods     = local.pods_range_name
  ip_range_services = local.svc_range_name

  issue_client_certificate = true

  release_channel                 = "REGULAR"
  create_service_account          = true
  enable_vertical_pod_autoscaling = true
}


resource "google_secret_manager_secret" "cloudquery" {
  secret_id = "${var.name}-secret"
  project   = var.project_id

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "cloudquery" {
  secret = google_secret_manager_secret.cloudquery.id

  secret_data = "postgres://default:${module.postgresql.generated_user_password}@${module.postgresql.private_ip_address}:5432/postgres"
}


module "private_service_access" {
  source      = "GoogleCloudPlatform/sql-db/google//modules/private_service_access"
  project_id  = var.project_id
  vpc_network = module.gcp_network.network_name
  depends_on = [module.gcp_network]
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

  ip_configuration = {
    ipv4_enabled        = true
    private_network     = module.gcp_network.network_self_link
    require_ssl         = false
    authorized_networks = []
    allocated_ip_range  = module.private_service_access.google_compute_global_address_name
  }
  depends_on = [
    module.gcp_network,
    module.private_service_access,
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
    data.google_service_account.gke_sa
  ]
}

resource "google_service_account_iam_binding" "workload_identity_user" {
  service_account_id = data.google_service_account.gke_sa.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${var.project_id}.svc.id.goog[cloudquery/${var.name}]",
  ]
}