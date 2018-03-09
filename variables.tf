variable "datadog_api_key" {
  default = "140eadc59c18abe373b43ca2cdaf9f97"
}

variable "datadog_app_key" {
  default = "0350319a97708813b6e73c7de6bca671f86f56c6"
}

variable "hopper_app_name" {
  default = "changelog-dashboard"
}

variable "newrelic_app_name" {
  default = "changelog_dashboard_production"
}

variable "services" {
  default = ["web"]
}

variable "env" {
  default = "production"
}