# ==============================================================================
# 1. Master Node
# ==============================================================================

resource "cloudru_evolution_compute_disk" "master_disk" {
  project_id  = var.project_id
  name        = "master-node-disk-v2"
  size        = 20
  zone        = { name = var.zone_name }
  disk_type   = { name = var.disk_type }
  description = "Boot disk for master-node"
  bootable    = true
  image       = { id = var.image_id }
  readonly    = false
  shared      = false
}

resource "cloudru_evolution_compute_vm" "master_node" {
  project_id  = var.project_id
  name        = "master-node-v2"
  zone        = { name = var.zone_name }
  flavor      = { name = var.vm_flavor }
  description = "Kubernetes Master Node"

  cloud_init_userdata = base64encode(templatefile("${path.module}/cloud-init.tftpl", {
    ssh_user       = "ubuntu"
    ssh_public_key = file(pathexpand(var.ssh_public_key_path))
    hostname       = "master-node"
  }))

  disks = [
    {
      id = cloudru_evolution_compute_disk.master_disk.id
    }
  ]

  network_interfaces = [
    {
      id = cloudru_evolution_compute_interface.master_interface.id
    }
  ]

  depends_on = [
    cloudru_evolution_compute_disk.master_disk,
    cloudru_evolution_compute_interface.master_interface
  ]
}

# ==============================================================================
# 2. Worker Node
# ==============================================================================

resource "cloudru_evolution_compute_disk" "worker_disk" {
  project_id  = var.project_id
  name        = "worker-node-disk-v2"
  size        = 20
  zone        = { name = var.zone_name }
  disk_type   = { name = var.disk_type }
  description = "Boot disk for worker-node"
  bootable    = true
  image       = { id = var.image_id }
  readonly    = false
  shared      = false
}

resource "cloudru_evolution_compute_vm" "node_worker" {
  project_id  = var.project_id
  name        = "worker-node-v2"
  zone        = { name = var.zone_name }
  flavor      = { name = var.vm_flavor }
  description = "Kubernetes Worker Node"

  cloud_init_userdata = base64encode(templatefile("${path.module}/cloud-init.tftpl", {
    ssh_user       = "ubuntu"
    ssh_public_key = file(pathexpand(var.ssh_public_key_path))
    hostname       = "worker-node"
  }))

  disks = [
    {
      id = cloudru_evolution_compute_disk.worker_disk.id
    }
  ]

  network_interfaces = [
    {
      id = cloudru_evolution_compute_interface.worker_interface.id
    }
  ]

  depends_on = [
    cloudru_evolution_compute_disk.worker_disk,
    cloudru_evolution_compute_interface.worker_interface
  ]
}

# ==============================================================================
# 3. Jenkins
# ==============================================================================

resource "cloudru_evolution_compute_disk" "jenkins_disk" {
  project_id  = var.project_id
  name        = "jenkins-disk-v2"
  size        = 30
  zone        = { name = var.zone_name }
  disk_type   = { name = var.disk_type }
  description = "Boot disk for Jenkins server"
  bootable    = true
  image       = { id = var.image_id }
  readonly    = false
  shared      = false
}

resource "cloudru_evolution_compute_vm" "jenkins" {
  project_id  = var.project_id
  name        = "jenkins-v2"
  zone        = { name = var.zone_name }
  flavor      = { name = var.vm_flavor }
  description = "Jenkins CI Server"

  cloud_init_userdata = base64encode(templatefile("${path.module}/cloud-init.tftpl", {
    ssh_user       = "ubuntu"
    ssh_public_key = file(pathexpand(var.ssh_public_key_path))
    hostname       = "jenkins"
  }))

  disks = [
    {
      id = cloudru_evolution_compute_disk.jenkins_disk.id
    }
  ]

  network_interfaces = [
    {
      id = cloudru_evolution_compute_interface.jenkins_interface.id
    }
  ]

  depends_on = [
    cloudru_evolution_compute_disk.jenkins_disk,
    cloudru_evolution_compute_interface.jenkins_interface
  ]
}

# ==============================================================================
# 4. Внешние IP-адреса
# ==============================================================================

resource "cloudru_evolution_compute_external_ip" "master" {
  project_id  = var.project_id
  name        = "master-ip-v2"
  zone        = { name = var.zone_name }
  description = "Внешний IP для master"
}

resource "cloudru_evolution_compute_external_ip" "worker" {
  project_id  = var.project_id
  name        = "worker-ip-v2"
  zone        = { name = var.zone_name }
  description = "Внешний IP для worker"
}

resource "cloudru_evolution_compute_external_ip" "jenkins" {
  project_id  = var.project_id
  name        = "jenkins-ip-v2"
  zone        = { name = var.zone_name }
  description = "Внешний IP для Jenkins"
}

# ==============================================================================
# 5. Сетевые интерфейсы (с привязкой внешних IP)
# ==============================================================================

resource "cloudru_evolution_compute_interface" "master_interface" {
  project_id                 = var.project_id
  name                       = "master-node-interface-v2"
  zone                       = { name = var.zone_name }
  description                = "Сетевой интерфейс для master"
  subnet                     = { id = cloudru_evolution_compute_subnet.subnet_devops.id }
  interface_security_enabled = true
  security_groups = [{
    id = cloudru_evolution_compute_security_group.devops_sg.id
  }]
  attach_external_ip = {
    id = cloudru_evolution_compute_external_ip.master.id
  }
  type = "INTERFACE_TYPE_REGULAR"
}

resource "cloudru_evolution_compute_interface" "worker_interface" {
  project_id                 = var.project_id
  name                       = "worker-node-interface-v2"
  zone                       = { name = var.zone_name }
  description                = "Сетевой интерфейс для worker"
  subnet                     = { id = cloudru_evolution_compute_subnet.subnet_devops.id }
  interface_security_enabled = true
  security_groups = [{
    id = cloudru_evolution_compute_security_group.devops_sg.id
  }]
  attach_external_ip = {
    id = cloudru_evolution_compute_external_ip.worker.id
  }
  type = "INTERFACE_TYPE_REGULAR"
}

resource "cloudru_evolution_compute_interface" "jenkins_interface" {
  project_id                 = var.project_id
  name                       = "jenkins-interface-v2"
  zone                       = { name = var.zone_name }
  description                = "Сетевой интерфейс для Jenkins"
  subnet                     = { id = cloudru_evolution_compute_subnet.subnet_devops.id }
  interface_security_enabled = true
  security_groups = [{
    id = cloudru_evolution_compute_security_group.devops_sg.id
  }]
  attach_external_ip = {
    id = cloudru_evolution_compute_external_ip.jenkins.id
  }
  type = "INTERFACE_TYPE_REGULAR"
}
