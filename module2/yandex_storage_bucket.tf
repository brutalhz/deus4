resource "yandex_iam_service_account" "sa" {
  folder_id = var.ya_folder_id
  name      = "sa-deus"
}
 
resource "yandex_resourcemanager_folder_iam_member" "sa-editor" {
  folder_id = var.ya_folder_id
  role      = "storage.editor"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
}
 
resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.sa.id
  description        = "Static access key for object storage"
}
 
resource "yandex_storage_bucket" "state" {
  bucket     = "deus"
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
}
