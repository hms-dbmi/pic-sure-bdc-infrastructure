
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
  default = "subnet-0eb9214bae20a5887"
}
variable "edge-subnet-us-east-1b-id" {
  type = string
  default = "subnet-0133b10d5ad6c00af"
}

variable "app-subnet-us-east-1a-id" {
  type = string
  default = "subnet-0133b10d5ad6c00af"
}
variable "app-subnet-us-east-1b-id" {
  type = string
  default = "subnet-086d870083fa0ee3e"
}

variable "db-subnet-us-east-1a-id" {
  type = string
  default = "subnet-0cb58662c07eb66ee"
}
variable "db-subnet-us-east-1b-id" {
  type = string
  default = "subnet-007e02001c2ef875f"
}

variable "db-subnet-group-name" {
  type = string
  default = "main"
}

variable "target-vpc" {
  type = string
  default = "vpc-03193ad72635a09ac"
}