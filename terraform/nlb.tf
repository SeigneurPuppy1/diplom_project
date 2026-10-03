# 1. Целевая группа (Target Group) с Worker-нодой
resource "yandex_lb_target_group" "k8s_nodes" {
  name      = "k8s-ingress-target-group"
  region_id = "ru-central1"

  target {
    subnet_id = yandex_vpc_subnet.subnet_devops.id
    address   = yandex_compute_instance.node_worker.network_interface.0.ip_address
  }
}

# 2. Сетевой балансировщик нагрузки
resource "yandex_lb_network_load_balancer" "ingress_nlb" {
  name = "k8s-ingress-nlb"

  # Листенер HTTP (порт 80 -> NodePort 30080)
  listener {
    name = "http-listener"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  # Листенер HTTPS (порт 443 -> NodePort 30443)
  listener {
    name = "https-listener"
    port = 443
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.k8s_nodes.id

    # Health check для проверки доступности Ingress NGINX
    healthcheck {
      name                = "http-healthcheck"
      interval            = 2
      timeout             = 1
      unhealthy_threshold = 2
      healthy_threshold   = 2
      http_options {
        port = 30080
        path = "/healthz"
      }
    }
  }
}
