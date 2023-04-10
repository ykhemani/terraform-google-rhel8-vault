provider "google" {
  project = var.google_project_id
  region  = var.google_region
  zone    = var.google_zone
}

#----------------------------------------------------------------------------------------------
# Network
#----------------------------------------------------------------------------------------------
resource "google_compute_network" "vpc" {
  count = var.vpc_name != null ? 1 : 0

  name                            = "${var.friendly_name_prefix}-${var.vpc_name}"
  routing_mode                    = "REGIONAL"
  auto_create_subnetworks         = false
  delete_default_routes_on_create = false
}

resource "google_compute_subnetwork" "subnet" {
  count = var.vpc_name != null && var.subnet_name != null ? 1 : 0

  name    = "${var.friendly_name_prefix}-${var.subnet_name}"
  network = google_compute_network.vpc[0].self_link
  #purpose                 = "PRIVATE" # available in beta provider
  ip_cidr_range            = var.subnet_cidr
  private_ip_google_access = true
}

resource "google_compute_router" "router" {
  count = var.vpc_name != null ? 1 : 0

  name    = "${var.friendly_name_prefix}-${var.vpc_name}-router"
  network = google_compute_network.vpc[0].self_link
}

resource "google_compute_router_nat" "nat" {
  count = var.vpc_name != null ? 1 : 0

  name                               = "${var.friendly_name_prefix}-${var.vpc_name}-router-nat"
  router                             = google_compute_router.router[0].name
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

#----------------------------------------------------------------------------------------------
# Firewalls
#----------------------------------------------------------------------------------------------
resource "google_compute_firewall" "https" {
  count = var.vpc_name != null ? 1 : 0

  name          = "${var.friendly_name_prefix}-${var.vpc_name}-firewall-https"
  network       = google_compute_network.vpc[0].self_link
  source_ranges = var.cidr_ingress_https_allow

  allow {
    protocol = "tcp"
    ports    = ["443", "80"]
  }
}

resource "google_compute_firewall" "vault" {
  count = var.vpc_name != null ? 1 : 0

  name          = "${var.friendly_name_prefix}-${var.vpc_name}-firewall-vault"
  network       = google_compute_network.vpc[0].self_link
  source_ranges = var.cidr_ingress_vault_allow

  allow {
    protocol = "tcp"
    ports    = ["8200"]
  }
}

resource "google_compute_firewall" "bastion" {
  count = var.subnet_name != null && var.bastion_name != null ? 1 : 0

  name    = "${var.friendly_name_prefix}-${var.vpc_name}-firewall-bastion-ssh"
  network = google_compute_network.vpc[0].name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = var.cidr_ingress_ssh_allow
  target_tags   = ["bastion"]
}

#----------------------------------------------------------------------------------------------
# HCP Packer Image
#----------------------------------------------------------------------------------------------
data "hcp_packer_image" "rhel8-hashicorp-vault" {
  bucket_name    = var.hcp_packer_bucket_name
  channel        = var.hcp_packer_channel
  cloud_provider = "gce"
  region         = var.google_zone
}

#----------------------------------------------------------------------------------------------
# Bastion
#----------------------------------------------------------------------------------------------
data "google_compute_zones" "available" {}

resource "google_compute_instance" "bastion" {
  count = var.subnet_name != null && var.bastion_name != null ? 1 : 0

  name           = "${var.friendly_name_prefix}-${var.bastion_name}"
  labels         = var.common_labels
  zone           = element(data.google_compute_zones.available.names, 0)
  machine_type   = var.bastion_machine_type
  can_ip_forward = true

  boot_disk {
    initialize_params {
      #image = "ubuntu-os-cloud/ubuntu-minimal-2204-lts"
      #image = "rhel-cloud/rhel-8"
      image = data.hcp_packer_image.rhel8-hashicorp-vault.cloud_image_id
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet[0].self_link
    access_config {
      network_tier = "STANDARD"
    }
  }

  #metadata_startup_script = "apt-get update -y"
  #metadata_startup_script = file("${path.module}/scripts/startup.sh")
  #   metadata_startup_script = <<-EOF
  # echo "Starting metadata startup script." >> /var/log/terraform.log

  # # install the epel repo and jq
  # echo "Intalling the epel repo and jq" >> /var/log/terraform.log
  # yum -y update && \
  #   yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm && \
  #   yum -y install jq

  # # install the HashiCorp repo and Vault Enterprise
  # echo "Intalling the HashiCorp repo and Vault Enterprise" >> /var/log/terraform.log
  # yum install -y yum-utils && \
  #   yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo && \
  #   yum install -y vault-enterprise

  # echo "Finished metadata startup script" >> /var/log/terraform.log
  # EOF


  tags = ["bastion"]
}