output "bastion_public_ip" {
  description = "Public IP address of bastion host"
  value       = yandex_compute_instance.bastion.network_interface[0].nat_ip_address
}

output "bi_portal_public_ip" {
  description = "Public IP address of BI Portal"
  value       = yandex_compute_instance.bi_portal.network_interface[0].nat_ip_address
}

output "data_lakehouse_private_ip" {
  description = "Private IP address of Data Lakehouse"
  value       = yandex_compute_instance.data_lakehouse.network_interface[0].ip_address
}

output "event_bus_private_ip" {
  description = "Private IP address of Event Bus (Kafka)"
  value       = yandex_compute_instance.event_bus.network_interface[0].ip_address
}

output "data_catalog_private_ip" {
  description = "Private IP address of Data Catalog"
  value       = yandex_compute_instance.data_catalog.network_interface[0].ip_address
}

output "fintech_private_ip" {
  description = "Private IP address of Fintech domain"
  value       = yandex_compute_instance.fintech.network_interface[0].ip_address
}

output "ai_private_ip" {
  description = "Private IP address of AI domain"
  value       = yandex_compute_instance.ai.network_interface[0].ip_address
}

output "vpc_network_id" {
  description = "VPC Network ID"
  value       = yandex_vpc_network.main.id
}

output "nat_gateway_id" {
  description = "NAT Gateway ID"
  value       = yandex_vpc_gateway.nat_gateway.id
}
