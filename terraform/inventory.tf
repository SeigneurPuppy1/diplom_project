# ==============================================================================
# Генерация инвентаря для Ansible
# ==============================================================================

resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/inventory.tftpl", {
    master_name        = cloudru_evolution_compute_vm.master_node.name
    master_ip          = cloudru_evolution_compute_external_ip.master.ip_address
    master_internal_ip = cloudru_evolution_compute_interface.master_interface.ip_address

    worker_name        = cloudru_evolution_compute_vm.node_worker.name
    worker_ip          = cloudru_evolution_compute_external_ip.worker.ip_address
    worker_internal_ip = cloudru_evolution_compute_interface.worker_interface.ip_address

    jenkins_name        = cloudru_evolution_compute_vm.jenkins.name
    jenkins_ip          = cloudru_evolution_compute_external_ip.jenkins.ip_address
    jenkins_internal_ip = cloudru_evolution_compute_interface.jenkins_interface.ip_address
  })

  filename = "${path.module}/../ansible/inventory.ini"

  depends_on = [
    cloudru_evolution_compute_vm.master_node,
    cloudru_evolution_compute_vm.node_worker,
    cloudru_evolution_compute_vm.jenkins,
    cloudru_evolution_compute_external_ip.master,
    cloudru_evolution_compute_external_ip.worker,
    cloudru_evolution_compute_external_ip.jenkins
  ]
}

# ==============================================================================
# Ожидание загрузки ОС на виртуальных машинах
# ==============================================================================

resource "time_sleep" "wait_for_cloud_init" {
  depends_on = [
    cloudru_evolution_compute_vm.master_node,
    cloudru_evolution_compute_vm.node_worker,
    cloudru_evolution_compute_vm.jenkins,
    local_file.ansible_inventory
  ]
  create_duration = "120s" # Увеличено до 2 минут для надежности
}

# ==============================================================================
# Запуск Ansible
# ==============================================================================

#resource "null_resource" "run_ansible" {
#  depends_on = [
#    local_file.ansible_inventory,
#    time_sleep.wait_for_cloud_init,
#    cloudru_evolution_nlb_network_load_balancer.ingress_nlb
#  ]

#  provisioner "local-exec" {
#    working_dir = "${path.module}/../ansible"
#    command     = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory.ini site.yml"
    
    # Таймаут для всего процесса Ansible (30 минут)
#    environment = {
#      ANSIBLE_TIMEOUT = "1800"
#    }
#  }

  # Перезапускать Ansible, если изменился инвентарь
#  triggers = {
#    inventory_hash = md5(local_file.ansible_inventory.content)
#  }
#}
