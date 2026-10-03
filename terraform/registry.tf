resource "yandex_container_registry" "devops_registry" {
  name      = "devops-registry"
  folder_id = var.folder_id

  labels = {
    project = "diplom-project"
  }
}
