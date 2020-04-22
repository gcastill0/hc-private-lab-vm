# Configure the Azure Provider
provider "azurerm" {
  # whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
  version = "=1.36.0"
}

data "terraform_remote_state" "azure_master" {
  backend = "atlas"

  config {
    name = "${var.tfe_organization}/${var.tfe_workspace}"
  }
}
