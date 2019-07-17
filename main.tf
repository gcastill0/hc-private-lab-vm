data "terraform_remote_state" "azure_master" {
  backend = "atlas"

  config {
    name = "${var.tfe_organization}/${var.tfe_workspace}"
  }
}

resource "azurerm_network_interface" "main" {
  count               = "${var.count}"
  name                = "NIC-${count.index + 1}-${data.terraform_remote_state.azure_master.postfix}"
  location            = "${data.terraform_remote_state.azure_master.azure_resource_group_location}"
  resource_group_name = "${data.terraform_remote_state.azure_master.azure_resource_group_name}"

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = "${data.terraform_remote_state.azure_master.azurerm_subnet_internal_id}"
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "main" {
  count                            = "${var.count}"
  name                             = "VM-${count.index + 1}-${data.terraform_remote_state.azure_master.postfix}"
  location                         = "${data.terraform_remote_state.azure_master.azure_resource_group_location}"
  resource_group_name              = "${data.terraform_remote_state.azure_master.azure_resource_group_name}"
  network_interface_ids            = ["${ element ( azurerm_network_interface.main.*.id,count.index) }"]
  vm_size                          = "Standard_DS1_v2"
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  # storage_image_reference {
  #   publisher = "Canonical"
  #   offer     = "UbuntuServer"
  #   sku       = "16.04-LTS"
  #   version   = "latest"
  # }

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2012-R2-Datacenter"
    version   = "latest"
  }
  storage_os_disk {
    name              = "DISK-${count.index + 1}-${data.terraform_remote_state.azure_master.postfix}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "VM-${count.index + 1}-${data.terraform_remote_state.azure_master.postfix}"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_windows_config {
    provision_vm_agent = true
  }

  # os_profile_linux_config {
  #   disable_password_authentication = false
  # }

  tags = {
    environment = "Staging"
  }
}
