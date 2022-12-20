# Secret vars
variable "ya_cloud_id" {
  description = "Yandex cloud_id"
  type = string
}

variable "ya_folder_id" {
  description = "Yandex folder_id"
  type = string
}

variable "ya_pub_key" {
  description = "yandex pub key"
  type = string
}

variable "private_key" {
  description = "local private key"
  type = string
  default = "~/.ssh/id_rsa"
}

variable "pub_key" {
  type = string
  default = "~/.ssh/id_rsa.pub"
}

variable "pass" {
  description = "password"
  type = string
}

variable "token" {
  description = "token"
  type = string
}

# Main vars
variable "yc_image_family_ubuntu" {
  description = "family"
  default = "ubuntu-1804-lts"
}

variable "yc_image_family_centos" {
  description = "family"
  default = "centos-7"
}

variable "zone" {
  description = "Yandex Cloud default Zone for provisioned resources"
  default = "ru-central1-a"
}

variable "instance_cores" {
  description = "Cores per one instance"
  default     = "2"
}

variable "instance_memory" {
  description = "Memory in GB per one instance"
  default     = "2"
}

variable "disk_size" {
  description = "Size of the disk in GB"
  default     = "25"
}

variable "platform_id" {
  description = "available options: standard-v1/standard-v2/standard-v3"
  default = "standard-v1"
}

variable "label" {
  description = "List of labels"
  type = map
}

variable "user" {
  type = string
  default = "denis_iddqd_at_gmail_com"
}

variable "user_ssh" {
  type = string
  default = "ubuntu"
}


