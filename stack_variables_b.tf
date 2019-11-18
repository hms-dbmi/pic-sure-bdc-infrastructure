
variable "edge-subnet-us-east-1a-cidr" {
  type = string
  default = "172.17.0.0/26"
}
variable "edge-subnet-us-east-1b-cidr" {
  type = string
  default = "172.17.0.64/26"
}

variable "app-subnet-us-east-1a-cidr" {
  type = string
  default = "172.17.1.0/26"
}
variable "app-subnet-us-east-1b-cidr" {
  type = string
  default = "172.17.1.64/26"
}

variable "db-subnet-us-east-1a-cidr" {
  type = string
  default = "172.17.3.0/26"
}
variable "db-subnet-us-east-1b-cidr" {
  type = string
  default = "172.17.3.64/26"
}

variable "edge-subnet-us-east-1a-id" {
  type = string
  default = "subnet-0f6b825238c1eed53"
}
variable "edge-subnet-us-east-1b-id" {
  type = string
  default = "subnet-046f9c9749ad2696c"
}

variable "app-subnet-us-east-1a-id" {
  type = string
  default = "subnet-0eb066d091d485fdf"
}
variable "app-subnet-us-east-1b-id" {
  type = string
  default = "subnet-0e297f89d8460f9a2"
}

variable "db-subnet-us-east-1a-id" {
  type = string
  default = "subnet-0c2c47cc211cfe868"
}
variable "db-subnet-us-east-1b-id" {
  type = string
  default = "subnet-0ec38f260860e61a7"
}

variable "db-subnet-group-name" {
  type = string
  default = "main"
}

variable "target-vpc" {
  type = string
  default = "vpc-00ccedc28fb73f39f"
}