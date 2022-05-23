module "cloudquery" {
    source = "../../"
    name = "cloudquery-complete-example"
    project_id = var.project_id

    config_file = "config.hcl"
}