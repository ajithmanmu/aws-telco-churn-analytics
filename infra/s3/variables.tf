variable "project" { type = string }
variable "env" { type = string }
variable "region" { type = string }
variable "use_kms" {
  type    = bool
  default = false
}
variable "kms_key_arn" {
  type    = string
  default = null
}
