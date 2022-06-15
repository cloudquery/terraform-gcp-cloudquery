module "cloudquery" {
  source      = "../../"
  name        = "cloudquery-complete-example"
  project_id  = var.project_id
  config_file = "config.hcl"

  # uncomment this if you want publicly accessible database. NOTE: it is strongly advised
  # to either avoid it and use cloudsql proxy or at least specify specific authorized_networks which are not 0.0.0.0/0
  # authorized_networks = [{name = "public", value = "0.0.0.0/0"}]

  # uncomment if you just want to setup the infrastructure without installing the helm chart
  # or do it seperatly
  # install_helm_chart  = false
}