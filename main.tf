variable "prefix" {
  default = "webserver"
}

variable "tfe_organization" {
  default = "gcastill0"
}

variable "tfe_workspace" {
  default = "azure-legacy"
}

data "terraform_remote_state" "azure_master" {
  backend = "atlas"

  config {
    name = "${var.tfe_organization}/${var.tfe_workspace}"
  }
}

resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic"
  location            = "${data.terraform_remote_state.azure_master.azure_resource_group_location}"
  resource_group_name = "${data.terraform_remote_state.azure_master.azure_resource_group_name}"

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = "${azurerm_subnet.internal.id}"
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "main" {
  name                  = "${var.prefix}-vm"
  location              = "${data.terraform_remote_state.azure_master.azure_resource_group_location}"
  resource_group_name   = "${data.terraform_remote_state.azure_master.azure_resource_group_name}"
  network_interface_ids = ["${azurerm_network_interface.main.id}"]
  vm_size               = "Standard_DS1_v2"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true


  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }
}
