resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/inventory.tftpl", {
    master_name        = yandex_compute_instance.master_node.name
    master_ip          = yandex_compute_instance.master_node.network_interface.0.nat_ip_address
    master_internal_ip = yandex_compute_instance.master_node.network_interface.0.ip_address

    worker_name        = yandex_compute_instance.node_worker.name
    worker_ip          = yandex_compute_instance.node_worker.network_interface.0.nat_ip_address
    worker_internal_ip = yandex_compute_instance.node_worker.network_interface.0.ip_address

    jenkins_name        = yandex_compute_instance.jenkins.name
    jenkins_ip          = yandex_compute_instance.jenkins.network_interface.0.nat_ip_address
    jenkins_internal_ip = yandex_compute_instance.jenkins.network_interface.0.ip_address
  })
  filename = "${path.module}/../ansible/inventory.ini"
}
