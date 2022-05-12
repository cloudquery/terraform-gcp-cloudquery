module "cloudquery" {
  source = "../../"

  name = "cloudquery-complete-example"

  project = "your-awesome-project"
  region  = "us-central1"
  zones = [
    "us-central1-a",
    "us-central1-b",
    "us-central1-c"
  ]

  config_file        = "config.hcl"
  install_helm_chart = true
}
