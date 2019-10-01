variable "environment_name" {
  description = "The name of the environment"
  type        = string
  default 	  = "picsure"
}

variable "rds_master_username" {
  description = "Master Username"
  type        = string
  default 	  = "root"
}

variable "rds_master_password" {
  description = "Master Password"
  type        = string
  default 	  = "picsure!98765"  
} 