terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">=0.13"
}

provider "yandex" {
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.zone
  service_account_key_file = pathexpand("~/.yc-keys/authorized_key")
}

# 1. Виртуальная частная сеть (VPC)
resource "yandex_vpc_network" "network_devops" {
  name        = "devops-vpc"
  description = "VPC сеть для дипломного проекта"
}

# 2. Подсеть
resource "yandex_vpc_subnet" "subnet_devops" {
  name           = "devops-subnet"
  zone           = var.zone
  network_id     = yandex_vpc_network.network_devops.id
  v4_cidr_blocks = ["10.10.0.0/24"]
}

# 3. Security Group для кластера и Jenkins
resource "yandex_vpc_security_group" "devops_sg" {
  name        = "devops-sg"
  network_id  = yandex_vpc_network.network_devops.id
  description = "Правила фильтрации входящего и исходящего трафика"

  # Разрешаем весь исходящий трафик
  egress {
    protocol       = "ANY"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  # Внутренний трафик между нодами без ограничений (K8s pod-to-pod, flannel/calico)
  ingress {
    protocol          = "ANY"
    from_port         = 0
    to_port           = 65535
    predefined_target = "self_security_group"
  }

  # Health checks от Yandex Network Load Balancer
  ingress {
    description       = "Health checks from Yandex NLB"
    protocol          = "TCP"
    from_port         = 0
    to_port           = 65535
    predefined_target = "loadbalancer_healthchecks"
  }

  # SSH доступ для управления через Ansible
  ingress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  # Веб-трафик к Ingress / NLB (HTTP & HTTPS)
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

  # Диапазон NodePort для проброса трафика с NLB на Ingress Controller
  ingress {
    protocol       = "TCP"
    from_port      = 30000
    to_port        = 32767
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  # Доступ к веб-интерфейсу Jenkins
  ingress {
    protocol       = "TCP"
    port           = 8080
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  # Доступ к Kubernetes API
  ingress {
    protocol       = "TCP"
    port           = 6443
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}
