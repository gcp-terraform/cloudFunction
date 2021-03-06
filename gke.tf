locals {
  name                      = "cluster-${var.regions.0}"
  notification_topic        = "${var.project_id}-gke-test"
  notification_config_topic = "projects/${var.project_id}/topics/${var.project_id}-gke-test"
}

resource "google_compute_network" "vpc" {
  project                 = var.project_id
  name                    = "vpc-network"
  auto_create_subnetworks = true
  mtu                     = 1460
}

resource "google_compute_subnetwork" "subnet" {
  name          = "subnetwork"
  ip_cidr_range = "10.2.0.0/16"
  region        = "us-west1"
  network       = google_compute_network.vpc.name
  secondary_ip_range {
    range_name    = "tf-test-secondary-range-update1"
    ip_cidr_range = "192.168.10.0/24"
  }
}

# GKE cluster
resource "google_container_cluster" "primary" {
  provider           = google-beta
  project            = var.project_id
  name               = "${var.project_id}-gke"
  location           = var.regions.0
  initial_node_count = 1
  network            = google_compute_network.vpc.name
  subnetwork         = google_compute_subnetwork.subnet.name

  //private_cluster_config {
   // enable_private_endpoint = false
    //enable_private_nodes    = true
   // master_ipv4_cidr_block  = var.gke_master_ipv4_cidr_block
  //}
  
//finds the notification to use
  notification_config {
    pubsub {
      enabled = true
      topic   = "projects/${var.project_id}/topics/${var.project_id}-gke-test"
    }
  }

  # Enable Autopilot for this cluster
  //enable_autopilot = true

  # Configuration of cluster IP allocation for VPC-native clusters
  //ip_allocation_policy {
   // cluster_secondary_range_name  = "pods"
   // services_secondary_range_name = "services"
 // }

}



/*
# Separately Managed Node Pool
resource "google_container_node_pool" "primary_nodes" {
  name       = "${google_container_cluster.primary.name}-node-pool"
  location   = "us-west1"
  cluster    = google_container_cluster.primary.name
  node_count = var.gke_num_nodes

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels = {
      env = var.project_id
    }

    # preemptible  = true
    machine_type = "n1-standard-1"
    tags         = ["gke-node", "${var.project_id}-gke"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}

*/
# # Kubernetes provider
# # The Terraform Kubernetes Provider configuration below is used as a learning reference only. 
# # It references the variables and resources provisioned in this file. 
# # We recommend you put this in another file -- so you can have a more modular configuration.
# # https://learn.hashicorp.com/terraform/kubernetes/provision-gke-cluster#optional-configure-terraform-kubernetes-provider
# # To learn how to schedule deployments and services using the provider, go here: https://learn.hashicorp.com/tutorials/terraform/kubernetes-provider.

# provider "kubernetes" {
#   load_config_file = "false"

#   host     = google_container_cluster.primary.endpoint
#   username = var.gke_username
#   password = var.gke_password

#   client_certificate     = google_container_cluster.primary.master_auth.0.client_certificate
#   client_key             = google_container_cluster.primary.master_auth.0.client_key
#   cluster_ca_certificate = google_container_cluster.primary.master_auth.0.cluster_ca_certificate
# }
