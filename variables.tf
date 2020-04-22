variable "win_count" {
  default = 0
}

variable "linux_count" {
  default = 0
}

variable "tfe_organization" {
  default = "gcastill0"
}

variable "tfe_workspace" {
  default = "azure-environment"
}

variable "tags" {
  type = "map"

  default = {
    Subscription = "Customer in Azure"
    Environment  = "Dev\\Test"
    Owner        = "Gilberto Castillo"
    Purpose      = "POC Test"
    Email        = "gilberto@hashicorp.com"
    Phone        = "416-543-7918"
    DoNotDelete  = "True"
  }

  description = "Basic tags"
}
