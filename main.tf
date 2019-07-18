data "terraform_remote_state" "azure_master" {
  backend = "atlas"

  config {
    name = "${var.tfe_organization}/${var.tfe_workspace}"
  }
}
