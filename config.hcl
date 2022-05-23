// Configuration AutoGenerated by CloudQuery CLI
cloudquery {
  plugin_directory = "./cq/providers"
  policy_directory = "./cq/policies"

  provider "gcp" {
    version = "latest"
  }

  connection {
    dsn = "postgres://postgres:pass@localhost:5432/postgres?sslmode=disable"
  }
}

// All Provider Configurations

provider "gcp" {
  configuration {
    // Optional. List of folders to get projects from. Required permission: resourcemanager.projects.list
    // folder_ids = [ "organizations/<ORG_ID>", "folders/<FOLDER_ID>" ]
    // Optional. Maximum level of folders to recurse into
    // folders_max_depth = 5
    // Optional. If not specified either using all projects accessible.
    // project_ids = [<CHANGE_THIS_TO_YOUR_PROJECT_ID>]
    // Optional. ServiceAccountKeyJSON passed as value instead of a file path, can be passed also via env: CQ_SERVICE_ACCOUNT_KEY_JSON
    // service_account_key_json = <YOUR_JSON_SERVICE_ACCOUNT_KEY_DATA>
    // Optional. GRPC Retry/backoff configuration, time units in seconds. Documented in https://github.com/grpc/grpc/blob/master/doc/connection-backoff.md
    // backoff_base_delay = 1
    // backoff_multiplier = 1.6
    // backoff_max_delay = 120
    // backoff_jitter = 0.2
    // backoff_min_connect_timeout = 0
    // Optional. Max amount of retries for retrier, defaults to max 3 retries.
    // max_retries = 3
  }
  // list of resources to fetch
  resources = [
    "bigquery.datasets",
    "cloudfunctions.functions",
    "compute.addresses",
    "compute.autoscalers",
    "compute.backend_services",
    "compute.disk_types",
    "compute.disks",
    "compute.firewalls",
    "compute.forwarding_rules",
    "compute.images",
    "compute.instances",
    "compute.interconnects",
    "compute.networks",
    "compute.projects",
    "compute.ssl_certificates",
    "compute.ssl_policies",
    "compute.subnetworks",
    "compute.target_http_proxies",
    "compute.target_https_proxies",
    "compute.target_ssl_proxies",
    "compute.url_maps",
    "compute.vpn_gateways",
    "dns.managed_zones",
    "dns.policies",
    "domains.registrations",
    "iam.project_roles",
    "iam.service_accounts",
    "kms.keys",
    "logging.metrics",
    "logging.sinks",
    "monitoring.alert_policies",
    "resource_manager.folders",
    "resource_manager.projects",
    "sql.instances",
    "storage.buckets",
    "storage.metrics"
  ]
}
