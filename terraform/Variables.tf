locals {
  glue_src_path = "D:\\CDAC\\Terraform\\ec2-tf1-script\\"
}

variable "project" {
    type=string
}

variable "engine_name" {
  description = "Enter the DB engine"
  type        = string
  default     = "mysql"
}


variable "db_name" {
  description = "Enter the name of the database to be created inside DB Instance"
  type        = string
  default     = "group4"
}
variable "user_name" {
  description = "Enter the username for DB"
  type        = string
  default     = "group4_dbda"
}
variable "pass" {
  description = "Enter the password for DB"
  type        = string
  default     = "group4123"
}
variable "multi_az_deployment" {
  description = "Enable or disable multi-az deployment"
  type        = bool
  default     = false
}
variable "public_access" {
  description = "Whether public access needed"
  type        = bool
  default     = true
}
variable "skip_finalSnapshot" {
  type    = bool
  default = true
}
variable "delete_automated_backup" {
  type    = bool
  default = true
}
variable "instance_class" {
  type    = string
  default = "db.t2.micro"
}
