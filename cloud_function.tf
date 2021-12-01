resource "google_pubsub_topic" "example" {
  name = "example-topic"

  labels = {
    foo = "bar"
  }

  message_retention_duration = "86600s"
}


# Compress source code

locals {
  timestamp = formatdate("YYMMDDhhmmss", timestamp())
  root_dir  = abspath("src/")
}
data "archive_file" "source" {
  type        = "zip"
  source_dir  = local.root_dir
  output_path = "index.zip"
}

# Create bucket that will host the source code
resource "google_storage_bucket" "bucket" {
  name     = "${var.project}-function"
  location = "US"
}

# Add source code zip to bucket
resource "google_storage_bucket_object" "zip" {
  # Append file MD5 to force bucket to be recreated>
  name   = "source.zip#${data.archive_file.source.output_md5}"
  bucket = google_storage_bucket.bucket.name
  source = data.archive_file.source.output_path
}

# Enable Cloud Functions API
resource "google_project_service" "cloud_function" {
  project = var.project
  service = "cloudfunctions.googleapis.com"

  disable_dependent_services = true
  disable_on_destroy         = false
}

# Enable Cloud Build API
resource "google_project_service" "cloud_build" {
  project = var.project
  service = "cloudbuild.googleapis.com"

  disable_dependent_services = true
  disable_on_destroy         = false
}
/*

module "cloudfunctions" {

  source  = "app.terraform.io/app/cloudfunctions/google"
  version = "~> 2.0"

  name    = local.function_name
  project = var.project

  trigger_http  = true
  entry_point   = "slackNotifier"
  trigger_topic = "gke-notification-${local.id}"

  runtime             = var.runtime
  region              = var.region
  available_memory_mb = var.available_memory_mb
  timeout             = var.timeout
  max_instances       = var.max_instances


  service_account_email = var.service_account_email
  environment_variables = local.environment_variables
  labels                = local.labels

  source_archive_bucket = var.cf_src_bucket
  source_archive_object = google_storage_bucket_object.source_object.name

  vpc_connector = var.vpc_access_connector


  event_trigger = {
    event_type = "providers/cloud.pubsub/eventTypes/topic.publish"
    resource   = "${google_pubsub_topic.mytopic.name}"
  }



}
*/
#creates bucket

resource "google_pubsub_topic" "example_pub" {
  name = "${var.project_id}-gke-test"

  labels = {
    foo = "bar"
  }

  message_retention_duration = "86600s"
}
#creates object & stores source
resource "google_storage_bucket_object" "archive" {
  name   = "index.zip"
  bucket = google_storage_bucket.bucket.name
  source = "src/index.zip"
}

#creates cloud function use pub also
resource "google_cloudfunctions_function" "function" {

  name                  = "gke_cluster_notification"
  description           = "Function created to run with pub/sun"
  runtime               = "nodejs14"
  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.bucket.name
  source_archive_object = google_storage_bucket_object.archive.name
  //trigger_http          = true
  timeout               = 60
  entry_point           = "slackNotifier"
  //trigger_topic         = "gke-notification-${local.id}"

  event_trigger {
    event_type = "providers/cloud.pubsub/eventTypes/topic.publish"
    resource   = google_pubsub_topic.example_pub.name
  }

}

# IAM entry for a single user to invoke the function
resource "google_cloudfunctions_function_iam_member" "invoker" {
  cloud_function = google_cloudfunctions_function.function.name
  project        = google_cloudfunctions_function.function.project
  region         = google_cloudfunctions_function.function.region

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}

