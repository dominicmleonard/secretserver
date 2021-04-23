variable "kv-ado-spn-appid" {}
variable "kv-ado-spn-password" {}
variable "kv-ado-spn-tenant" {}
variable "kv-admin-user-password" {}
variable location-name {
  type    = string
  default = "westeurope"
}
variable "servername" {
  type    = string
  default = "secrectserver01"
}