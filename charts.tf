locals {
  dsn    = "postgres://${var.db_user}:${module.sql-db.generated_user_password}@${module.sql-db.private_ip_address}/${var.db_name}"
  labels = merge(
    {
      cloudquery = var.name
    },
    var.labels,
  )
}

data "google_client_config" "provider" {}

provider "helm" {
  kubernetes {
    host                   = "https://${module.gke.endpoint}"
    cluster_ca_certificate = base64decode(module.gke.ca_certificate)
    token                  = data.google_client_config.provider.access_token
  }
}

resource "helm_release" "cloudquery" {
  for_each         = toset(var.install_helm_chart ? ["cloudquery"] : [])
  name             = var.name
  namespace        = var.namespace
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
  CQ_VAR_DSN: ${local.dsn}
config: |
  ${indent(2, file(var.config_file))}
EOT
  ,
    var.chart_values
  ]

  depends_on = [
    module.gke.cluster_id,
  ]
}
