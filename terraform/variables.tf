variable "kv-win-admin-password" {
  type    = string
  default = "#{kv-win-admin-password}#"
}
variable location-name {
  type    = string
  default = "westeurope"
}
variable "servername" {
  type    = string
  default = "#{pl-server-name}#"
}
variable "resourcegroup" {
  type    = string
  default = "#{pl-rg-name}#"
}
