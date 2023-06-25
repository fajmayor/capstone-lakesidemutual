terraform {
  backend "s3" {
    bucket  = "microservice-project-terraform-state"
    key     = "microservice-project-terraform.tfstate"
    region  = "us-west-2"
    profile = "fajmayor"
  }
}