output "secrectserver_pub_ip" {
  description = "Public IP Address of SecretServer"
  value       = azurerm_public_ip.myterraformpublicip.ip_address
}