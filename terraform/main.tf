resource "azurerm_resource_group" "thycotic" {
  name     = "thycotic-rg-001"
  location = var.location-name
}

## <https://www.terraform.io/docs/providers/azurerm/r/virtual_network.html>
resource "azurerm_virtual_network" "vnet" {
  name                = "vNet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.thycotic.location
  resource_group_name = azurerm_resource_group.thycotic.name
}

## <https://www.terraform.io/docs/providers/azurerm/r/subnet.html> 
resource "azurerm_subnet" "subnet" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.thycotic.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_public_ip" "myterraformpublicip" {
    name                = "myPublicIP"
    location            = azurerm_resource_group.thycotic.location
    resource_group_name = azurerm_resource_group.thycotic.name
    allocation_method   = "Dynamic"

}

resource "azurerm_network_security_group" "myterraformnsg" {
    name                = "myNetworkSecurityGroup"
    location            = azurerm_resource_group.thycotic.location
    resource_group_name = azurerm_resource_group.thycotic.name

    security_rule {
        name                       = "RDP"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "3389"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "https"
        priority                   = 1002
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "winrm"
        priority                   = 1003
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "5986"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    
}
## <https://www.terraform.io/docs/providers/azurerm/r/network_interface.html>
resource "azurerm_network_interface" "internal" {
  name                = "internal-nic"
  location            = azurerm_resource_group.thycotic.location
  resource_group_name = azurerm_resource_group.thycotic.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.myterraformpublicip.id
  }
}

## <https://www.terraform.io/docs/providers/azurerm/r/windows_virtual_machine.html>
resource "azurerm_windows_virtual_machine" "secretserver" {
  name                = var.servername
  resource_group_name = azurerm_resource_group.thycotic.name
  location            = azurerm_resource_group.thycotic.location
  size                = "Standard_B2ms"
  admin_username      = "adminuser"
  admin_password      = var.kv-admin-user-password
  network_interface_ids = [
    azurerm_network_interface.internal.id,
  ]

os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}

resource "azurerm_virtual_machine_extension" "vmext" {
  name                 = azurerm_windows_virtual_machine.secretserver.name
  virtual_machine_id   = azurerm_windows_virtual_machine.secretserver.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = <<SETTINGS
    {
        "commandToExecute": "powershell -ExecutionPolicy Unrestricted -File ConfigureRemotingForAnsible.ps1",
        "fileUris": ["https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1"]
    }
SETTINGS

}