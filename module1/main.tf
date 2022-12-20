terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  token = var.token 
  cloud_id  = var.ya_cloud_id
  folder_id = var.ya_folder_id
  zone      = var.zone
}


# Configure the AWS Provider

data "yandex_vpc_network" "custom-net" {
  network_id = "enpfbfss98rdsa3tpj55"
}

resource "yandex_vpc_subnet" "custom-subnet" {
  v4_cidr_blocks = ["192.168.15.0/24"]
  name           = "sub_brutal-network"
  zone           = "ru-central1-a"
  network_id     = data.yandex_vpc_network.custom-net.id
}

data "yandex_compute_image" "base_image_ubuntu" {
  family = var.yc_image_family_ubuntu
}

## Create a new Yandex Cloud instance for load balancer
resource "yandex_compute_instance" "dev2" {
  name        = "deus"
  hostname    = "deus"
  platform_id = var.platform_id
  labels = var.label
  
  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.base_image_ubuntu.id
      size = var.disk_size
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.custom-subnet.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.pub_key)}"
  }

}
