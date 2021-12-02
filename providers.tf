
provider "google" {

  project = var.project
  region  = "us-west1"
  zone    = "us-west1-a"

  //version = "~> 1.20.0"
}

provider "google-beta" {

}

