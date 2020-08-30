# Create a Resource Group
resource "azurerm_resource_group" "main" {
  name     = "${var.VM_NAME}-ResourceGroup"
  location = var.LOCATION
}

# Create a Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = "${var.VM_NAME}-network"
  address_space       = ["10.0.1.0/24"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

# Create a Subnet
resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefix       = "10.0.1.0/28"
}

# Create a Virtual Machine
resource "azurerm_virtual_machine" "main" {
  name                  = var.VM_NAME
  location              = azurerm_resource_group.main.location
  resource_group_name   = azurerm_resource_group.main.name
  network_interface_ids = [azurerm_network_interface.main.id]
  vm_size               = "Standard_B1ms"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.VM_NAME}-OS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "StandardSSD_LRS"
    disk_size_gb      = 32
  }

  os_profile {
    computer_name  = var.VM_NAME
    admin_username = var.VM_ADMIN
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      key_data = var.DEFAULT_SSHKEY
      path     = "/home/azure-admin/.ssh/authorized_keys"
    }
  }

  tags = {
    environment = "test"
    deployment  = "terraform"
  }
}

# Create a Network Interface 
resource "azurerm_network_interface" "main" {
  name                = "${var.VM_NAME}-nic01"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "ipconfiguration01"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main.id
  }
}

# Create a Public IP
resource "azurerm_public_ip" "main" {
  name                = "${var.VM_NAME}-publicip01"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"
}
