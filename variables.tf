variable "google_project_id" {
  type        = string
  description = "Google Cloud project id."
}

variable "google_region" {
  type        = string
  description = "Google Cloud region."
  default     = "us-central1"
}

variable "google_zone" {
  type        = string
  description = "Google Cloud zone."
  default     = "us-central1-c"
}

variable "friendly_name_prefix" {
  type        = string
  description = "Friendly name prefix for GCP resource names."
}

variable "common_labels" {
  type        = map(string)
  description = "Common labels to apply to GCP resources."
  default     = {}
}

#----------------------------------------------------------------------------------------------
# Network
#----------------------------------------------------------------------------------------------
variable "vpc_name" {
  type        = string
  description = "Name of VPC network to create."
  default     = null
}

variable "subnet_name" {
  type        = string
  description = "Name of subnet to create. `vpc_name` is required."
  default     = null
}

variable "subnet_cidr" {
  type        = string
  description = "CIDR range of VPC subnetwork to create. `vpc_name` and subnet_name` are required."
  default     = "10.0.0.0/24"
}

variable "cidr_ingress_ssh_allow" {
  type        = list(string)
  description = "Source CIDR ranges to allow for SSH traffic into VPC (for bastion)."
  default     = []
}

variable "cidr_ingress_https_allow" {
  type        = list(string)
  description = "Source CIDR ranges to allow for HTTPS traffic into VPC."
  default     = []
}

variable "cidr_ingress_vault_allow" {
  type        = list(string)
  description = "Source CIDR ranges to allow for Vault traffic into VPC."
  default     = []
}

#----------------------------------------------------------------------------------------------
# HCP Packer
#----------------------------------------------------------------------------------------------
variable "hcp_packer_bucket_name" {
  type        = string
  description = "Name of HCP Packer Bucket for bastion host image."
  default     = "rhel8-hashicorp-vault"
}

variable "hcp_packer_channel" {
  type        = string
  description = "Name of HCP Packer Channel for bastion host image."
  default     = "demo"
}

#----------------------------------------------------------------------------------------------
# Bastion
#----------------------------------------------------------------------------------------------
variable "bastion_name" {
  type        = string
  description = "Name of bastion VM instance. `subnet_name` is required."
  default     = null
}

variable "bastion_machine_type" {
  type        = string
  description = "Bastion machine type."
  default     = "e2-micro"
}