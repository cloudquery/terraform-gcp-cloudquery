# # data "aws_eks_cluster_auth" "cluster" {
# #   name = module.eks.cluster_id
# # }

module "gke_auth" {
  source = "terraform-google-modules/kubernetes-engine/google//modules/auth"
  # version = "~> 10.0"

  # project_id   = module.project_services.project_id
  project_id   = var.project_id
  cluster_name = module.gke.name
  location     = module.gke.location

  # depends_on = [time_sleep.sleep_for_cluster_fix_helm_6361]
}


provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

provider "helm" {
  kubernetes {
    # load_config_file       = false
    cluster_ca_certificate = module.gke_auth.cluster_ca_certificate
    host                   = module.gke_auth.host
    token                  = module.gke_auth.token
  }
}

resource "helm_release" "cloudquery" {
  for_each         = toset(var.install_helm_chart ? ["cloudquery"] : [])
  name             = var.name
  namespace        = "cloudquery"
  repository       = "https://cloudquery.github.io/helm-charts"
  chart            = "cloudquery"
  version          = var.chart_version
  create_namespace = true
  wait             = true
  values = [
    <<EOT
serviceAccount:
  enabled: true
  name: "${var.name}"
  autoMount: true
  annotations:
    iam.gke.io/gcp-service-account: ${data.google_service_account.gke_sa.email}
envRenderSecret:
  "CQ_VAR_DSN": "postgres://default:${module.postgresql.generated_user_password}@${module.postgresql.private_ip_address}:5432/postgres"
config: |
  ${indent(2, file(var.config_file))}
EOT
    ,
    var.chart_values
  ]

  # depends_on = [
  #   module.eks.cluster_id,
  # ]
}