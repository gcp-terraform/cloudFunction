locals {
  project = "${module.naming.environment}-${module.naming.location_global_short}-${module.naming.purpose}"
}

module "naming" {
  source  = "app.terraform.io/dexcom/naming/google"
  version = "~> 2.0"

  environment    = var.environment
  departmentcode = var.departmentcode
  purpose        = var.purpose
  location       = var.location
  owner_email    = var.owner_email
}

module "project" {
  source  = "app.terraform.io/dexcom/project/google"
  version = "~> 1.0"

  environment       = module.naming.environment_long
  name              = local.project
  random_project_id = false
  labels            = module.naming.labels
  folder_id         = var.folder_id
  #shared_vpc        = true
  shared_vpc            = false
  project_services      = var.project_services
  project_role_members  = var.project_role_members
  project_role_bindings = var.project_role_bindings
}

resource "google_privateca_ca_pool" "capool" {
  for_each = toset(var.regions)
  project  = module.project.project_id
  name     = "pool-${each.key}"
  location = each.key
  tier     = "ENTERPRISE"
  # TODO
  labels = module.naming.labels
  publishing_options {
    publish_ca_cert = true
    publish_crl     = true
  }
}

resource "google_privateca_certificate_authority" "ca" {
  for_each = toset(var.regions)
  project  = module.project.project_id
  // Pools cannot be deleted in normal test circumstances, so we depend on static pools
  pool = "pool-${each.key}"
  #pool                     = google_privateca_ca_pool.capool[each.key].id
  certificate_authority_id = "ca-${each.key}"
  location                 = each.key
  lifetime                 = "315360000s"
  # SUBORDINATE Certificate Authorities need to be manually activated (via Cloud Console)
  # type = "SELF_SIGNED"
  type = "SUBORDINATE"
  key_spec {
    algorithm = "RSA_PKCS1_4096_SHA256"
    #algorithm = "RSA_PSS_2048_SHA256"
  }
  config {
    subject_config {
      subject {
        organization        = "dexcom"
        common_name         = "Dexcom IT CAS Certificate Authority"
        country_code        = "us"
        organizational_unit = "it"
        locality            = "san diego"
        province            = "california"
        # when CSR is signed these are stripped
        #street_address      = "6340 Sequence Dr"
        #postal_code         = "92121"
      }
    }
    x509_config {
      ca_options {
        is_ca                  = true
        max_issuer_path_length = 10
      }
      key_usage {
        base_key_usage {
          digital_signature  = true
          content_commitment = true
          key_encipherment   = false
          data_encipherment  = true
          key_agreement      = true
          cert_sign          = true
          crl_sign           = true
          decipher_only      = true
        }
        extended_key_usage {
          server_auth      = true
          client_auth      = false
          email_protection = true
          code_signing     = true
          time_stamping    = true
        }
      }
    }
  }
}

/*
TODO
  for_each = toset(var.regions)

apiVersion: cas-issuer.jetstack.io/v1beta1
kind: GoogleCASClusterIssuer
metadata:
  name: googlecasclusterissuer-${each.key}
spec:
  project: ${var.cas_project}
  location: ${each.key}
  caPoolId: pool-${each.key}
*/
