
variable "project" {
  default = "second-project-325919"
}
variable "project_id" {
  default = "second-project-325919"
}

variable "notification_config_topic" {
  default = ""
}

variable "environment" {
  description = "Environment, e.g. 'dv', 'pd', 'uat', 'sb', 'tst'"
  type        = string
  default     = "pd"
}

variable "location" {
  description = "GCP region"
  type        = string
  # REALLY SHOULD BE GLOBAL BUT NOT SUPPORTED
  default = "us"
}

variable "purpose" {
  description = "Purpose of the resources, for naming and labeling"
  type        = string
  default     = "cas"
}

variable "folder_id" {
  description = "The folder id in the dexcom.com organization associated with the project"
  type        = string
  default     = "240679432441" # IT-8Q/SharedServices
}

variable "departmentcode" {
  description = "Department code, 5 digits"
  type        = string
  default     = "71030"
}

variable "owner_email" {
  description = "email of owner"
  type        = string
  default     = ""
}
/*
variable "project_services" {
  description = "API services enabled on project."
  type        = list(string)
  default = [
    "cloudkms.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "containerregistry.googleapis.com",
    "dns.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "oslogin.googleapis.com",
    "privateca.googleapis.com",
    "serviceusage.googleapis.com",
    "stackdriver.googleapis.com",
    "storage-api.googleapis.com",
  ]
}

variable "project_role_members" {
  description = "Map of role names to members of that role."
  type        = map(list(string))
  default = {
    "dev"    = ["group:it-gcp-integrations@dexcom.com"]
    "devops" = ["group:it-gcp-admin@dexcom.com"]
    "admin"  = ["group:it-gcp-admin@dexcom.com"]
    "secops" = ["group:it-gcp-iam-admin@dexcom.com", "group:it-infosec@dexcom.com"]
    "viewer" = ["group:it-gcp-admin@dexcom.com", "group:it-gcp-integrations@dexcom.com", "group:it-gcp-support@dexcom.com", "group:it-infosec@dexcom.com"]
  }
}

variable "project_role_bindings" {
  description = "Map of roles to role names."
  type        = map(list(string))
  default = {
    "roles/cloudkms.admin"                 = ["admin"]
    "roles/container.admin"                = ["admin", "dev"]
    "roles/container.clusterAdmin"         = ["admin", "dev"]
    "roles/container.developer"            = ["dev"]
    "roles/dns.admin"                      = ["admin"]
    "roles/errorreporting.admin"           = ["admin"]
    "roles/errorreporting.viewer"          = ["viewer"]
    "roles/logging.admin"                  = ["admin"]
    "roles/logging.configWriter"           = ["admin"]
    "roles/logging.viewer"                 = ["admin"]
    "roles/monitoring.admin"               = ["admin"]
    "roles/monitoring.alertPolicyEditor"   = ["admin"]
    "roles/monitoring.viewer"              = ["viewer"]
    "roles/owner"                          = ["admin"]
    "roles/privateca.auditor"              = ["secops"]
    "roles/privateca.certificateRequester" = ["admin", "devops", "dev"]
    "roles/privateca.certificateManager"   = ["admin", "devops"]
    "roles/privateca.caManager"            = ["admin"]
    "roles/privateca.admin"                = ["admin"]
    "roles/logging.privateLogViewer"       = ["secops"]
    "roles/serviceusage.serviceUsageAdmin" = ["admin"]
    "roles/stackdriver.accounts.editor"    = ["admin"]
    "roles/storage.admin"                  = ["admin"]
    "roles/storage.objectAdmin"            = ["admin"]
    "roles/storage.objectViewer"           = ["viewer"]
  }
}
*/
variable "regions" {
  description = "GCP region"
  type        = list(string)
  #default     = ["us-west2","us-west4","europe-west3","europe-west1"] 
  default = ["us-west2", "europe-west3"]
}
