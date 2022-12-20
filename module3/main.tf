terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.9.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "2.4.1"
    }
  }

  backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "deus"
    region     = "ru-central1-a"
    key        = "terraform/infrastructure1/terraform.tfstate"
    access_key = "<access_key>"
    secret_key = "<secret_key>"
 
    skip_region_validation      = true
    skip_credentials_validation = true
  }

}

provider "yandex" {
  token = var.token 
  cloud_id  = var.ya_cloud_id
  folder_id = var.ya_folder_id
  zone      = var.zone
}

provider "helm" {
  kubernetes {
    config_path = pathexpand(var.kube_config)
  }
}

provider "kubernetes" {
  config_path = pathexpand(var.kube_config)
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
  depends_on = [
    data.yandex_vpc_network.custom-net,
  ]
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
# Postgresql cluster
resource "yandex_mdb_postgresql_cluster" "deus_sql" {
  name                = "deus_sql"
  environment         = "PRESTABLE"
  network_id          = data.yandex_vpc_network.custom-net.id
  security_group_ids  = [ yandex_vpc_security_group.pgsql-s.id ]
  deletion_protection = true

  config {
    version = 14
    resources {
      resource_preset_id = "s2.micro"
      disk_type_id       = "network-ssd"
      disk_size          = "20"
    }
  }

  host {
    zone      = var.zone
    name      = "mypg-host-a"
    subnet_id = yandex_vpc_subnet.custom-subnet.id
  }
}

resource "yandex_mdb_postgresql_database" "db1" {
  cluster_id = yandex_mdb_postgresql_cluster.deus_sql.id
  name       = "db1"
  owner      = "user1"
  depends_on = [ yandex_mdb_postgresql_user.user1, ]
}

resource "yandex_mdb_postgresql_user" "user1" {
  cluster_id = yandex_mdb_postgresql_cluster.deus_sql.id
  name       = "user1"
  password   = "user1user1"
}

resource "yandex_vpc_security_group" "pgsql-s" {
  name       = "pgsql-s"
  network_id = data.yandex_vpc_network.custom-net.id

  ingress {
    description    = "PostgreSQL"
    port           = 6432
    protocol       = "TCP"
    v4_cidr_blocks = [ "0.0.0.0/0" ]
  }
}
