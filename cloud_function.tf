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
  output_path = "indexOld.zip"
}

# Create bucket that will host the source code
resource "google_storage_bucket" "bucket" {
  name     = "${var.project}-function"
  location = "US"
}
/*
# Add source code zip to bucket
resource "google_storage_bucket_object" "zip" {
  # Append file MD5 to force bucket to be recreated>
  name   = "source.zip#${data.archive_file.source.output_md5}"
  bucket = google_storage_bucket.bucket.name
  source = data.archive_file.source.output_path
}*/

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

#creates bucket
resource "google_pubsub_topic" "example_pub" {
  name = "${var.project_id}-gke-test"

  labels = {
    foo = "bar"
  }

  message_retention_duration = "86600s"
}

#creates object & stores source
resource "google_storage_bucket_object" "js1" {
  name   = "indexOld.zip"
  bucket = "${google_storage_bucket.bucket.name}"
  source = "src/index.js"
}

#creates object & stores source
resource "google_storage_bucket_object" "js2" {
  name   = "indexOld.zip"
  bucket = "${google_storage_bucket.bucket.name}"
  source = "src/package.js"
}

#creates object & stores source
resource "google_storage_bucket_object" "archive" {
  name   = "indexOld.zip"
  bucket = "${google_storage_bucket.bucket.name}"
  source = "src/indexOld.zip"
}

#creates cloud function use pub also
resource "google_cloudfunctions_function" "function" {

  name                  = "gke_cluster_notification"
  description           = "Function created to run with pub/sun"
  runtime               = "nodejs12"
  available_memory_mb   = 128
  source_archive_bucket = "${google_storage_bucket.bucket.name}"
  source_archive_object = "${google_storage_bucket_object.archive.name}"
  //trigger_http          = true
  timeout     = 60
  entry_point = "slackNotifier"
  //trigger_topic = "${var.project_id}-gke-test"

  event_trigger {
    //event_type = "google.pubsub.topic.publish"
    //resource   = "projects/${var.project_id}/topics/${var.project_id}-gke-test"
    event_type = "providers/cloud.pubsub/eventTypes/topic.publish"
    resource = "${var.project_id}-gke-test"
    //--notification-config=pubsub=ENABLED,pubsub-topic=projects/second-project-325919/topics/example-topic
  }



  environment_variables = {
    SLACK_WEBHOOK_URL = "https://hooks.slack.com/services/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"
    //ZONE       = var.zone
    //CLUSTER    = var.cluster
    //NODEPOOL   = var.nodepool
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
