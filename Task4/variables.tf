variable "yandex_token" {
  description = "Yandex Cloud OAuth token"
  type        = string
  sensitive   = true
}

variable "cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
}

variable "folder_id" {
  description = "Yandex Cloud Folder ID"
  type        = string
}

variable "zone" {
  description = "Yandex Cloud zone"
  type        = string
  default     = "ru-central1-a"
}

variable "image_id" {
  description = "Ubuntu image ID"
  type        = string
  default     = "fd8kdq6d0p8sij7h5qe3" # Ubuntu 22.04 LTS
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key file"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

# VM ресурсы
variable "data_lakehouse_cores" {
  description = "Number of CPU cores for Data Lakehouse VM"
  type        = number
  default     = 8
}

variable "data_lakehouse_memory" {
  description = "Memory in GB for Data Lakehouse VM"
  type        = number
  default     = 32
}

variable "kafka_cores" {
  description = "Number of CPU cores for Kafka VM"
  type        = number
  default     = 4
}

variable "kafka_memory" {
  description = "Memory in GB for Kafka VM"
  type        = number
  default     = 16
}

variable "catalog_cores" {
  description = "Number of CPU cores for Data Catalog VM"
  type        = number
  default     = 4
}

variable "catalog_memory" {
  description = "Memory in GB for Data Catalog VM"
  type        = number
  default     = 16
}

variable "fintech_cores" {
  description = "Number of CPU cores for Fintech domain VM"
  type        = number
  default     = 4
}

variable "fintech_memory" {
  description = "Memory in GB for Fintech domain VM"
  type        = number
  default     = 16
}

variable "ai_cores" {
  description = "Number of CPU cores for AI domain VM"
  type        = number
  default     = 8
}

variable "ai_memory" {
  description = "Memory in GB for AI domain VM"
  type        = number
  default     = 32
}

variable "bi_cores" {
  description = "Number of CPU cores for BI Portal VM"
  type        = number
  default     = 4
}

variable "bi_memory" {
  description = "Memory in GB for BI Portal VM"
  type        = number
  default     = 16
}

# Диски
variable "data_disk_type" {
  description = "Type of data disk (network-ssd, network-hdd)"
  type        = string
  default     = "network-ssd"
}

variable "data_disk_size" {
  description = "Size of Data Lakehouse disk in GB"
  type        = number
  default     = 500
}

variable "fintech_disk_size" {
  description = "Size of Fintech data disk in GB"
  type        = number
  default     = 200
}

variable "ai_disk_size" {
  description = "Size of AI data disk in GB"
  type        = number
  default     = 300
}
