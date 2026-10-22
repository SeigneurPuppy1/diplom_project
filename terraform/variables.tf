variable "project_id" {
  type        = string
  description = "ID проекта из console.cloud.ru"
}

variable "auth_key_id" {
  type        = string
  description = "Key ID для Cloud.ru"
}

variable "auth_secret" {
  type        = string
  sensitive   = true
  description = "Secret для Cloud.ru"
}

variable "zone_name" {
  type        = string
  default     = "ru.AZ-2"
  description = "Зона доступности"
}

variable "image_id" {
  type        = string
  default     = "fe51a6e6-a5ad-410e-b441-1a195208a8cf"
  description = "UUID базового образа ОС"
}

variable "disk_type" {
  type        = string
  default     = "network-ssd"
  description = "Тип диска: network-hdd или network-ssd"
}

variable "subnet_cidr" {
  type        = string
  default     = "10.10.0.0/24"
  description = "CIDR подсети"
}

variable "ssh_public_key_path" {
  type        = string
  default     = "~/.ssh/id_rsa.pub"
  description = "Путь к публичному SSH-ключу для ВМ"
}

variable "ssh_private_key_path" {
  type        = string
  default     = "~/.ssh/id_rsa"
  description = "Путь к приватному SSH-ключу для Ansible"
}

variable "vm_flavor" {
  type        = string
  default     = "gen-2-4"
  description = "Flavor (тип ВМ) для виртуальных машин"
}
