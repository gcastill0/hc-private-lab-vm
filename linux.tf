resource "azurerm_network_interface" "linux" {
  count               = "${var.linux_count}"
  name                = "NIC-LNX-${count.index + 1}-${data.terraform_remote_state.azure_master.postfix}"
  location            = "${data.terraform_remote_state.azure_master.azure_resource_group_location}"
  resource_group_name = "${data.terraform_remote_state.azure_master.azure_resource_group_name}"

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = "${data.terraform_remote_state.azure_master.azurerm_subnet_internal_id}"
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "linux" {
  count                            = "${var.linux_count}"
  name                             = "LNX-${count.index + 1}-${data.terraform_remote_state.azure_master.postfix}"
  location                         = "${data.terraform_remote_state.azure_master.azure_resource_group_location}"
  resource_group_name              = "${data.terraform_remote_state.azure_master.azure_resource_group_name}"
  network_interface_ids            = ["${element(azurerm_network_interface.linux.*.id, count.index)}"]
  vm_size                          = "Standard_DS1_v2"
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "DISK-LNX-${count.index + 1}-${data.terraform_remote_state.azure_master.postfix}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "LNX-${count.index + 1}-${data.terraform_remote_state.azure_master.postfix}"
    admin_username = "hcadmin"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/hcadmin/.ssh/authorized_keys"
      key_data = "${data.terraform_remote_state.azure_master.hcadmin_rsa}"

    }
  }

  tags = {
    environment = "Staging"
  }
}
