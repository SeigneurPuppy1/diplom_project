# ============================================
# Целевая группа (Target Group)
# ============================================
resource "cloudru_evolution_nlb_target_group" "k8s_ingress" {
  name       = "tg-k8s-ingress-v2"
  project_id = var.project_id

  target_vms = [
    {
      id           = cloudru_evolution_compute_vm.node_worker.id
      interface_id = cloudru_evolution_compute_interface.worker_interface.id
    }
  ]

  depends_on = [
    cloudru_evolution_compute_vm.node_worker,
    cloudru_evolution_compute_interface.worker_interface
  ]
}

# ============================================
# Балансировщик нагрузки (HTTP + HTTPS)
# ============================================
resource "cloudru_evolution_nlb_network_load_balancer" "ingress_nlb" {
  name       = "nlb-k8s-ingress-v2"
  project_id = var.project_id

  vpc_id = cloudru_evolution_vpc_vpc.network_devops.id

  availability_zones = [
    {
      name = var.zone_name
      subnets = [
        {
          id = cloudru_evolution_compute_subnet.lb_subnet.id
        }
      ]
    }
  ]

  external_address = {
    allocate = true
  }

  rules = [
    {
      name                = "tcp-ingress-rule"
      algorithm           = "ALG_ROUND_ROBIN"
      target_group_id     = cloudru_evolution_nlb_target_group.k8s_ingress.id
      session_persistence = false

      listeners = [
        {
          name        = "http-listener"
          port        = 80
          target_port = 30080
          protocol    = "TCP"
        },
        {
          name        = "https-listener"
          port        = 443
          target_port = 30443
          protocol    = "TCP"
        }
      ]
    }
  ]

  depends_on = [
    cloudru_evolution_nlb_target_group.k8s_ingress,
    cloudru_evolution_compute_subnet.lb_subnet
  ]
}
