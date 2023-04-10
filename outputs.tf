output "network_name" {
  value       = google_compute_network.vpc[*].name
  description = "Name of the VPC Network"
}

output "subnet_name" {
  value       = google_compute_subnetwork.subnet[*].name
  description = "Name of the subnet"
}

output "bastion_ip" {
  value       = google_compute_instance.bastion[*].network_interface.0.access_config.0.nat_ip
  description = "Public IP of bastion instance."
}