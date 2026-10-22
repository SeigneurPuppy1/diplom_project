terraform {
  required_providers {
    cloudru = {
      source  = "cloudru/cloud"
      version = "2.1.3"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
    }
  }
}

provider "cloudru" {
  auth_key_id = var.auth_key_id
  auth_secret = var.auth_secret
}

# ==============================================================================
# 1. Сеть (VPC)
# ==============================================================================
resource "cloudru_evolution_vpc_vpc" "network_devops" {
  project_id  = var.project_id
  name        = "devops-vpc-v2"
  description = "VPC сеть для devops инфраструктуры (v2)"
}

# ==============================================================================
# 2. Основная подсеть
# ==============================================================================
resource "cloudru_evolution_compute_subnet" "subnet_devops" {
  project_id     = var.project_id
  name           = "devops-subnet-v2"
  description    = "Подсеть для devops-инфраструктуры"
  zone           = { name = var.zone_name }
  subnet_address = "10.10.0.0/24"
  vpc_id         = cloudru_evolution_vpc_vpc.network_devops.id
  dns_servers    = { value = ["8.8.4.4", "8.8.8.8"] }

  default = true # Оставляем true только для основной подсети

  lifecycle {
    ignore_changes = [dns_servers, default] # Защищаем от дрейфа состояния
  }

  routed_network = true
}

# ==============================================================================
# 3. Security Group
# ==============================================================================
resource "cloudru_evolution_compute_security_group" "devops_sg" {
  project_id  = var.project_id
  name        = "devops-sg-v2"
  zone        = { name = var.zone_name }
  description = "Правила фильтрации входящего и исходящего трафика"
}

# Исходящий TCP-трафик
resource "cloudru_evolution_compute_security_group_rule" "egress_tcp" {
  security_group_id = cloudru_evolution_compute_security_group.devops_sg.id
  direction         = "TRAFFIC_DIRECTION_EGRESS"
  ether_type        = "ETHER_TYPE_IPV4"
  ip_protocol       = "IP_PROTOCOL_TCP"
  port_range        = "1:65535"
  remote_ip_prefix  = "0.0.0.0/0"
}

# Исходящий UDP-трафик
resource "cloudru_evolution_compute_security_group_rule" "egress_udp" {
  security_group_id = cloudru_evolution_compute_security_group.devops_sg.id
  direction         = "TRAFFIC_DIRECTION_EGRESS"
  ether_type        = "ETHER_TYPE_IPV4"
  ip_protocol       = "IP_PROTOCOL_UDP"
  port_range        = "1:65535"
  remote_ip_prefix  = "0.0.0.0/0"
}

# Внутренний TCP-трафик подсети (K8s pod/node network, CNI)
resource "cloudru_evolution_compute_security_group_rule" "ingress_internal_tcp" {
  security_group_id = cloudru_evolution_compute_security_group.devops_sg.id
  direction         = "TRAFFIC_DIRECTION_INGRESS"
  ether_type        = "ETHER_TYPE_IPV4"
  ip_protocol       = "IP_PROTOCOL_TCP"
  port_range        = "1:65535"
  remote_ip_prefix  = "10.10.0.0/24"
}

# Внутренний UDP-трафик подсети (K8s pod/node network, CNI)
resource "cloudru_evolution_compute_security_group_rule" "ingress_internal_udp" {
  security_group_id = cloudru_evolution_compute_security_group.devops_sg.id
  direction         = "TRAFFIC_DIRECTION_INGRESS"
  ether_type        = "ETHER_TYPE_IPV4"
  ip_protocol       = "IP_PROTOCOL_UDP"
  port_range        = "1:65535"
  remote_ip_prefix  = "10.10.0.0/24"
}

# SSH
resource "cloudru_evolution_compute_security_group_rule" "ingress_ssh" {
  security_group_id = cloudru_evolution_compute_security_group.devops_sg.id
  direction         = "TRAFFIC_DIRECTION_INGRESS"
  ether_type        = "ETHER_TYPE_IPV4"
  ip_protocol       = "IP_PROTOCOL_TCP"
  port_range        = "22:22"
  remote_ip_prefix  = "0.0.0.0/0"
}

# HTTP
resource "cloudru_evolution_compute_security_group_rule" "ingress_http" {
  security_group_id = cloudru_evolution_compute_security_group.devops_sg.id
  direction         = "TRAFFIC_DIRECTION_INGRESS"
  ether_type        = "ETHER_TYPE_IPV4"
  ip_protocol       = "IP_PROTOCOL_TCP"
  port_range        = "80:80"
  remote_ip_prefix  = "0.0.0.0/0"
}

# HTTPS
resource "cloudru_evolution_compute_security_group_rule" "ingress_https" {
  security_group_id = cloudru_evolution_compute_security_group.devops_sg.id
  direction         = "TRAFFIC_DIRECTION_INGRESS"
  ether_type        = "ETHER_TYPE_IPV4"
  ip_protocol       = "IP_PROTOCOL_TCP"
  port_range        = "443:443"
  remote_ip_prefix  = "0.0.0.0/0"
}

# NodePort (30000-32767)
resource "cloudru_evolution_compute_security_group_rule" "ingress_nodeport" {
  security_group_id = cloudru_evolution_compute_security_group.devops_sg.id
  direction         = "TRAFFIC_DIRECTION_INGRESS"
  ether_type        = "ETHER_TYPE_IPV4"
  ip_protocol       = "IP_PROTOCOL_TCP"
  port_range        = "30000:32767"
  remote_ip_prefix  = "0.0.0.0/0"
}

# Jenkins Web UI
resource "cloudru_evolution_compute_security_group_rule" "ingress_jenkins" {
  security_group_id = cloudru_evolution_compute_security_group.devops_sg.id
  direction         = "TRAFFIC_DIRECTION_INGRESS"
  ether_type        = "ETHER_TYPE_IPV4"
  ip_protocol       = "IP_PROTOCOL_TCP"
  port_range        = "8080:8080"
  remote_ip_prefix  = "0.0.0.0/0"
}

# Kubernetes API
resource "cloudru_evolution_compute_security_group_rule" "ingress_k8s_api" {
  security_group_id = cloudru_evolution_compute_security_group.devops_sg.id
  direction         = "TRAFFIC_DIRECTION_INGRESS"
  ether_type        = "ETHER_TYPE_IPV4"
  ip_protocol       = "IP_PROTOCOL_TCP"
  port_range        = "6443:6443"
  remote_ip_prefix  = "0.0.0.0/0"
}

# ==============================================================================
# 4. Подсеть для NLB
# ==============================================================================
resource "cloudru_evolution_compute_subnet" "lb_subnet" {
  project_id     = var.project_id
  name           = "lb-subnet-v2"
  description    = "Подсеть для Network Load Balancer"
  zone           = { name = var.zone_name }
  subnet_address = "10.21.0.0/24"
  vpc_id         = cloudru_evolution_vpc_vpc.network_devops.id
  dns_servers    = { value = ["8.8.4.4", "8.8.8.8"] }

  default = false # <-- false, чтобы не конфликтовать с subnet_devops

  lifecycle {
    ignore_changes = [dns_servers, default] # <-- ДОБАВЛЕНО: default, чтобы избежать ошибки inconsistent result
  }

  routed_network = true
}
