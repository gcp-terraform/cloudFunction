
provider "google" {
  project = var.project
  region  = "us-west1"
  zone    = "us-west1-a"
}
provider "google-beta" {
}
