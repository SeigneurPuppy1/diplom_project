# ==============================================================================
# Выводы
# ==============================================================================

output "jenkins_external_url" {
  description = "URL для входа в веб-интерфейс Jenkins"
  value       = "http://${cloudru_evolution_compute_external_ip.jenkins.ip_address}:8080"
}

output "master_node_public_ip" {
  description = "Публичный IP мастера Kubernetes"
  value       = cloudru_evolution_compute_external_ip.master.ip_address
}

output "worker_node_public_ip" {
  description = "Публичный IP воркера Kubernetes"
  value       = cloudru_evolution_compute_external_ip.worker.ip_address
}

# =============================================================================
# Готовые URL для быстрой проверки работы инфраструктуры
# =============================================================================

output "nlb_access_urls" {
  description = "Готовые URL для доступа к сервисам через NLB"
  value = {
    jenkins = "https://jenkins.azeti.online"
    grafana  = "https://grafana.azeti.online"
    kibana   = "https://kibana.azeti.online"
    golang   = "https://golang.azeti.online"
  }
}

