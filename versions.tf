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
    aviatrix = {
      source  = "aviatrixsystems/aviatrix"
      version = "~> 2.24.0"
    }
  }
}