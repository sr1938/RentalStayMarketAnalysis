
variable "engine_name" {
  description = "DB engine name"
  type        = string
  default     = "mysql"
}
variable "db_name" {
  description = "name of db instance"
  type        = string
  default     = "group4"
}
variable "user_name" {
  description = "username for db instance"
  type        = string
  default     = "group4_dbda"
}
variable "pass" {
  description = "password for db instance"
  type        = string
  default     = "123456789"
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
