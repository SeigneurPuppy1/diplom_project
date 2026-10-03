output "jenkins_external_url" {
  description = "URL для входа в веб-интерфейс Jenkins"
  value       = "http://${yandex_compute_instance.jenkins.network_interface.0.nat_ip_address}:8080"
}

output "nlb_public_ip" {
  description = "Публичный IP балансировщика для A-записи домена"
  value       = tolist(tolist(yandex_lb_network_load_balancer.ingress_nlb.listener)[0].external_address_spec)[0].address
}

output "master_node_public_ip" {
  description = "Публичный IP мастера Kubernetes"
  value       = yandex_compute_instance.master_node.network_interface.0.nat_ip_address
}
