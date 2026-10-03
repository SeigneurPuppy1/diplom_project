variable "cloud_id" {
  type        = string
  description = "ID облака"
}

variable "folder_id" {
  type        = string
  description = "ID каталога"
}

variable "zone" {
  type        = string
  default     = "ru-central1-b"
  description = "Зона доступности по умолчанию"
}

variable "subnet_cidr" {
  type        = list(string)
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
  description = "Путь к приватному SSH-ключу для генерации инвентаря Ansible"
}

variable "ubuntu_image_family" {
  type        = string
  default     = "ubuntu-2404-lts"
  description = "Базовый образ для виртуальных машин"
}
