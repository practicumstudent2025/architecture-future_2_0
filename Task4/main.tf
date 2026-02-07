terraform {
  required_version = ">= 1.0"
  
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.100"
    }
  }
}

provider "yandex" {
  token     = var.yandex_token
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.zone
}

# VPC и подсети
resource "yandex_vpc_network" "main" {
  name = "future-2-0-network"
}

resource "yandex_vpc_subnet" "public" {
  name           = "public-subnet"
  zone           = var.zone
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = ["10.0.1.0/24"]
}

resource "yandex_vpc_subnet" "private_fintech" {
  name           = "private-fintech-subnet"
  zone           = var.zone
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = ["10.0.2.0/24"]
  route_table_id = yandex_vpc_route_table.private.id
}

resource "yandex_vpc_subnet" "private_ai" {
  name           = "private-ai-subnet"
  zone           = var.zone
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = ["10.0.3.0/24"]
  route_table_id = yandex_vpc_route_table.private.id
}

resource "yandex_vpc_subnet" "private_medical" {
  name           = "private-medical-subnet"
  zone           = var.zone
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = ["10.0.4.0/24"]
  route_table_id = yandex_vpc_route_table.private.id
}

resource "yandex_vpc_subnet" "private_data" {
  name           = "private-data-subnet"
  zone           = var.zone
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = ["10.0.5.0/24"]
  route_table_id = yandex_vpc_route_table.private.id
}

# NAT Gateway для доступа в интернет из приватных подсетей
resource "yandex_vpc_gateway" "nat_gateway" {
  name = "nat-gateway"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "private" {
  name       = "private-route-table"
  network_id = yandex_vpc_network.main.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
}

# Security Groups
resource "yandex_vpc_security_group" "public" {
  name       = "public-sg"
  network_id = yandex_vpc_network.main.id

  ingress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "TCP"
    port           = 443
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "private" {
  name       = "private-sg"
  network_id = yandex_vpc_network.main.id

  ingress {
    protocol          = "ANY"
    from_port         = 0
    to_port           = 65535
    predefined_target = "self_security_group"
  }

  ingress {
    protocol       = "TCP"
    port           = 9092
    v4_cidr_blocks = ["10.0.0.0/16"]
    description    = "Kafka"
  }

  ingress {
    protocol       = "TCP"
    port           = 8080
    v4_cidr_blocks = ["10.0.0.0/16"]
    description    = "Data Catalog"
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# Диски для данных
resource "yandex_compute_disk" "data_lakehouse" {
  name     = "data-lakehouse-disk"
  type     = var.data_disk_type
  zone     = var.zone
  size     = var.data_disk_size
}

resource "yandex_compute_disk" "fintech_data" {
  name     = "fintech-data-disk"
  type     = var.data_disk_type
  zone     = var.zone
  size     = var.fintech_disk_size
}

resource "yandex_compute_disk" "ai_data" {
  name     = "ai-data-disk"
  type     = var.data_disk_type
  zone     = var.zone
  size     = var.ai_disk_size
}

# Виртуальные машины

# Bastion host для доступа к приватным сетям
resource "yandex_compute_instance" "bastion" {
  name        = "bastion-host"
  platform_id = "standard-v2"
  zone        = var.zone

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
      size     = 20
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public.id
    nat                 = true
    security_group_ids  = [yandex_vpc_security_group.public.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.ssh_public_key_path)}"
  }
}

# Data Lakehouse VM
resource "yandex_compute_instance" "data_lakehouse" {
  name        = "data-lakehouse"
  platform_id = "standard-v2"
  zone        = var.zone

  resources {
    cores  = var.data_lakehouse_cores
    memory = var.data_lakehouse_memory
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
      size     = 50
    }
  }

  secondary_disk {
    disk_id = yandex_compute_disk.data_lakehouse.id
  }

  network_interface {
    subnet_id         = yandex_vpc_subnet.private_data.id
    security_group_ids = [yandex_vpc_security_group.private.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.ssh_public_key_path)}"
  }
}

# Event Bus (Kafka) VM
resource "yandex_compute_instance" "event_bus" {
  name        = "event-bus-kafka"
  platform_id = "standard-v2"
  zone        = var.zone

  resources {
    cores  = var.kafka_cores
    memory = var.kafka_memory
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
      size     = 50
    }
  }

  network_interface {
    subnet_id         = yandex_vpc_subnet.private_data.id
    security_group_ids = [yandex_vpc_security_group.private.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.ssh_public_key_path)}"
  }
}

# Data Catalog VM
resource "yandex_compute_instance" "data_catalog" {
  name        = "data-catalog"
  platform_id = "standard-v2"
  zone        = var.zone

  resources {
    cores  = var.catalog_cores
    memory = var.catalog_memory
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
      size     = 30
    }
  }

  network_interface {
    subnet_id         = yandex_vpc_subnet.private_data.id
    security_group_ids = [yandex_vpc_security_group.private.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.ssh_public_key_path)}"
  }
}

# Финтех домен VM
resource "yandex_compute_instance" "fintech" {
  name        = "fintech-domain"
  platform_id = "standard-v2"
  zone        = var.zone

  resources {
    cores  = var.fintech_cores
    memory = var.fintech_memory
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
      size     = 30
    }
  }

  secondary_disk {
    disk_id = yandex_compute_disk.fintech_data.id
  }

  network_interface {
    subnet_id         = yandex_vpc_subnet.private_fintech.id
    security_group_ids = [yandex_vpc_security_group.private.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.ssh_public_key_path)}"
  }
}

# AI домен VM
resource "yandex_compute_instance" "ai" {
  name        = "ai-domain"
  platform_id = "standard-v2"
  zone        = var.zone

  resources {
    cores  = var.ai_cores
    memory = var.ai_memory
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
      size     = 30
    }
  }

  secondary_disk {
    disk_id = yandex_compute_disk.ai_data.id
  }

  network_interface {
    subnet_id         = yandex_vpc_subnet.private_ai.id
    security_group_ids = [yandex_vpc_security_group.private.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.ssh_public_key_path)}"
  }
}

# Self-service BI Portal VM
resource "yandex_compute_instance" "bi_portal" {
  name        = "bi-portal"
  platform_id = "standard-v2"
  zone        = var.zone

  resources {
    cores  = var.bi_cores
    memory = var.bi_memory
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
      size     = 30
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public.id
    nat                 = true
    security_group_ids  = [yandex_vpc_security_group.public.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.ssh_public_key_path)}"
  }
}
