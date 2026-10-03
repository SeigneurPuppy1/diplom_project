# Шаблон метаданных cloud-init (пользователь ubuntu + публичный ключ)
locals {
  common_metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

# --- 1. Master Node ---
resource "yandex_compute_instance" "master_node" {
  name        = "master-node"
  hostname    = "master-node"
  platform_id = "standard-v3"
  zone        = "ru-central1-b"

  resources {
    cores         = 2
    memory        = 4
    core_fraction = 100
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 20
      type     = "network-ssd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet_devops.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.devops_sg.id]
  }

  scheduling_policy {
    preemptible = false
  }

  metadata = local.common_metadata
}

# --- 2. Worker Node ---
resource "yandex_compute_instance" "node_worker" {
  name        = "worker-node"
  hostname    = "worker-node"
  platform_id = "standard-v3"
  zone        = "ru-central1-b"

  resources {
    cores         = 2
    memory        = 4
    core_fraction = 100
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 20
      type     = "network-ssd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet_devops.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.devops_sg.id]
  }

  scheduling_policy {
    preemptible = false
  }

  metadata = local.common_metadata
}

# --- 3. Jenkins CI Server ---
resource "yandex_compute_instance" "jenkins" {
  name        = "jenkins"
  hostname    = "jenkins"
  platform_id = "standard-v3"
  zone        = "ru-central1-b"

  resources {
    cores         = 2
    memory        = 4
    core_fraction = 100
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 30
      type     = "network-ssd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet_devops.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.devops_sg.id]
  }

  scheduling_policy {
    preemptible = false
  }

  metadata = local.common_metadata
}
