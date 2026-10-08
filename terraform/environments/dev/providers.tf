provider "aws" {
  region  = "us-east-1"
  profile = "astronomy-dev"

  default_tags {
    tags = {
      Project     = "AstronomyShop"
      Environment = "Development"
      ManagedBy   = "Terraform"
      Owner       = "William"
    }
  }
}
