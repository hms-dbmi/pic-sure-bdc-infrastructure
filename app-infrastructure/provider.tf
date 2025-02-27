provider "aws" {
  region  = "us-east-1"
  profile = "avillachlab-secure-infrastructure"
  version = "3.74"
}

provider "template" {
  version = "2.2.0"
}

provider "random" {
  version = "3.6.3"
}
provider "local" {
  version = "2.5.2"
}
