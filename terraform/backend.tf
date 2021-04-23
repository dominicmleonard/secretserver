terraform {
  backend "azurerm" {
    storage_account_name = "terradom01"
    container_name       = "backend"
    key                  = "secrectserver.tfstate"
  }
}