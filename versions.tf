terraform {
  required_providers {
    equinix = {
      source  = "equinix/equinix"
      version = "~> 1.10.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.37.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.30.0"
    }
    aviatrix = {
      source  = "aviatrixsystems/aviatrix"
      version = "~> 2.24.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "aviatrix" {
  skip_version_validation = true
}