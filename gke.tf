locals {
  cluster_name       = var.name
  network_name       = var.name
  subnet_name        = "${var.name}-subnet"
  master_subnet_name = "${var.name}-master-subnet"
  pods_range_name    = "${var.name}-pods"
  svc_range_name     = "${var.name}-service"
  subnet_names       = [for subnet_self_link in module.gcp-network.subnets_self_links : split("/", subnet_self_link)[length(split("/", subnet_self_link)) - 1]]
}

module "gke" {
  source                          = "registry.terraform.io/terraform-google-modules/kubernetes-engine/google"
  project_id                      = var.project
  name                            = local.cluster_name
  regional                        = true
  region                          = var.region
  network                         = module.gcp-network.network_name
  subnetwork                      = local.subnet_names[index(module.gcp-network.subnets_names, local.subnet_name)]
  ip_range_pods                   = local.pods_range_name
  ip_range_services               = local.svc_range_name
  release_channel                 = "REGULAR"
  create_service_account          = true
  enable_vertical_pod_autoscaling = true
  cluster_resource_labels         = local.labels
}

// allow list and read
data "google_service_account" "gke_sa" {
  account_id = module.gke.service_account
}

resource "google_project_iam_binding" "project" {
  project = var.project
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
    "serviceAccount:${var.project}.svc.id.goog[${var.namespace}/${var.name}]",
  ]
}
