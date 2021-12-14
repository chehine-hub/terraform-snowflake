variable "LISTE_PRODUCTEURS" {
  type    = list
}

variable "SNOWFLAKE_ENV" {
  type     = string
}

variable "SNOWFLAKE_ACCOUNT" {
  type     = string
  default  = "za76125"
}

variable "SNOWFLAKE_PRIVATE_KEY_PATH" {
  type     = string
  default  = "/home/vsts/work/_temp/rsa_private_key.p8"
}

variable "SNOWFLAKE_REGION" {
  type     = string
  default  = "ca-central-1.aws"
}

variable "SNOWFLAKE_SYSADMIN_ROLE" {
  type     = string
  default  = "SYSADMIN"
}

variable "SNOWFLAKE_SECURITYADMIN_ROLE" {
  type     = string
  default  = "SECURITYADMIN"
}

variable "SNOWFLAKE_USER" {
  type     = string
  default  = "chehine"
}
