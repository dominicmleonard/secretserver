provider "azurerm" {
  version = "= 2.37.0"
  features {}
  subscription_id = "d33d79f1-a9c6-4447-a91d-0e711037aeb0"
  client_id       = var.kv-ado-spn-appid
  client_secret   = var.kv-ado-spn-password
  tenant_id       = var.kv-ado-spn-tenant
}