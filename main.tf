terraform {
  backend "s3" {}
  required_providers {
    snowflake = {
      source = "chanzuckerberg/snowflake"
      version = "0.25.1"
    }
  }
}

provider snowflake {
  alias             = "sysadmin"
  username          = var.SNOWFLAKE_USER
  account           = var.SNOWFLAKE_ACCOUNT
  region            = var.SNOWFLAKE_REGION
  private_key_path  = var.SNOWFLAKE_PRIVATE_KEY_PATH
  role              = var.SNOWFLAKE_SYSADMIN_ROLE
}

provider snowflake {
  alias             = "securityadmin"
  username          = var.SNOWFLAKE_USER
  account           = var.SNOWFLAKE_ACCOUNT
  region            = var.SNOWFLAKE_REGION
  private_key_path  = var.SNOWFLAKE_PRIVATE_KEY_PATH
  role              = var.SNOWFLAKE_SECURITYADMIN_ROLE
}

###################################################
########## CREATION DES SERVICE ACCOUNTS ##########
###################################################

# CREATE SERVICE ACCOUNT
resource snowflake_user sa {
  provider         = snowflake.securityadmin
  for_each         = toset(var.LISTE_PRODUCTEURS)
  name             = "SERVICE_ACCOUNT_${each.key}_${var.SNOWFLAKE_ENV}"
  rsa_public_key   = "MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAxqPBFEgzvcQZtbyXDsSS/H/3J8hL6qk2UpQ8MKcBW68mhFWJ7hKlfyxeWoXrdnrmz1y4q/sM3go1KL6Sl6KDgfz5AW5zQ61juzNbVTy9XcrGR4EF1RJs7CuUHcggD8/guF3FJBz4m7OIH4wWwEzBqoFQ0l0SaB7Gv+JIAm1vSo/rv/QcVf9JJm0mc3oFWmvWNg92k3ZDegtHqLyko9liuZmB4+mgwPsEr8BgfcK/4QfEcVhzxG72/9Fa+dWRZdxKKRf4bfC8rJ+lahSiuZL4g4vVEruuLsyqouXYdNDJNXqrJ8oc9BAt3voiMvW/rf8Su8ujAKbw3ijeKuPGXo/BVyhWomDvZrNIiM03mJOu2n6MjU4eMGxLpZF177vf+UHctKDxF9Ecx9EnmqsCEGklhyfTWwNvjVO4zjwEW6k62h7/wZDhxo5KZ3mKaGEEkGiJhvRT7/RXMSSIxoKYS2UH7r2ac5xDYIH4Zs/gP83W9Sn35w7ZnmkzgkEUmemMfsnQch9s776pzIHIW0VY8otAxjPlaBg8wmJm2QmExGgDRd14B5TCVhi7WG4+njwTt1GKvMBNqxTuHt+nLnvTrjoE2JQ7B7xcucdq5h9ws3suE2IV2RIl5xw76tqUW7JquCrEIgTCpzyge5y5iUS8lixkHnBX13KQqLcQ23pEN0RGz3ECAwEAAQ=="
}

#######################################
######### CREATION DES ROLES ##########
#######################################

# CREATE ROLE DEPLOYMENT
resource snowflake_role rf_deployment {
  provider    = snowflake.securityadmin
  for_each    = toset(var.LISTE_PRODUCTEURS)
  name        = "ROLE_${each.key}_DEPLOYMENT_${var.SNOWFLAKE_ENV}"
}

# CREATE ROLE SUPPORT
resource snowflake_role rf_support {
  provider    = snowflake.securityadmin
  for_each    = toset(var.LISTE_PRODUCTEURS)
  name        = "ROLE_${each.key}_SUPPORT_${var.SNOWFLAKE_ENV}"
}

# CREATE DATABASE READ ROLE
resource snowflake_role database_read {
  provider    = snowflake.securityadmin
  for_each    = toset(var.LISTE_PRODUCTEURS)
  name        = "ROLE_DB_${each.key}_SUPPORT_${var.SNOWFLAKE_ENV}_LEC"
}

# CREATE DATABASE WRITE ROLE
resource snowflake_role database_write {
  provider    = snowflake.securityadmin
  for_each    = toset(var.LISTE_PRODUCTEURS)
  name        = "ROLE_DB_${each.key}_SUPPORT_${var.SNOWFLAKE_ENV}_ECR"
}

# CREATE DATABASE DEPLOY ROLE
resource snowflake_role database_deploy {
  provider    = snowflake.securityadmin
  for_each    = toset(var.LISTE_PRODUCTEURS)
  name        = "ROLE_DB_${each.key}_SUPPORT_${var.SNOWFLAKE_ENV}_DEPLOY"
}

############################################
######### CREATION DES WAREHOUSES ##########
############################################

# CREATE WAREHOUSES 
resource snowflake_warehouse warehouse {
  provider       = snowflake.sysadmin
  for_each       = toset(var.LISTE_PRODUCTEURS)
  name           = "${each.key}_${var.SNOWFLAKE_ENV}_WH"
  warehouse_size = "xsmall"
}

############################################
########## CREATION DES DATABASES ##########
############################################

# CREATE DATABASES
resource snowflake_database database {
  provider    = snowflake.sysadmin
  for_each    = toset(var.LISTE_PRODUCTEURS)
  name        = "DB_${each.key}_${var.SNOWFLAKE_ENV}"
}

#########################################
########## CREATION DES GRANTS ##########
#########################################


# GRANT DATABASES USAGE GRANTS
resource snowflake_database_grant usage_database_grant {
  provider          = snowflake.securityadmin
  for_each          = toset(var.LISTE_PRODUCTEURS)
  database_name     = snowflake_database.database[each.key].name
  privilege         = "USAGE"
  roles             = [snowflake_role.database_read[each.key].name, snowflake_role.database_write[each.key].name, snowflake_role.database_deploy[each.key].name]
  with_grant_option = false
}

# GRANT ROLE DEPLOYMENT TO SERVICE ACCOUNT
resource snowflake_role_grants grant_rf_deployment_sa {
  provider    = snowflake.securityadmin
  for_each    = toset(var.LISTE_PRODUCTEURS)
  role_name   = snowflake_role.rf_deployment[each.key].name
  roles       = ["SYSADMIN"]
  users       = [snowflake_user.sa[each.key].name]
}

# GRANT ROLE SUPPORT TO SYSADMIN
resource snowflake_role_grants grant_rf_support_sysadmin {
  provider    = snowflake.securityadmin
  for_each    = toset(var.LISTE_PRODUCTEURS)
  role_name   = snowflake_role.rf_support[each.key].name
  roles       = ["SYSADMIN"]
}

# GRANT ROLE DATABASE_READ TO SYSADMIN
resource snowflake_role_grants grant_db_read_sysadmin {
  provider    = snowflake.securityadmin
  for_each    = toset(var.LISTE_PRODUCTEURS)
  role_name   = snowflake_role.database_read[each.key].name
  roles       = ["SYSADMIN"]
}

# GRANT ROLE DATABASE_WRITE TO SYSADMIN
resource snowflake_role_grants grant_db_write_sysadmin {
  provider    = snowflake.securityadmin
  for_each    = toset(var.LISTE_PRODUCTEURS)
  role_name   = snowflake_role.database_write[each.key].name
  roles       = ["SYSADMIN"]
}

# GRANT ROLE DATABASE_DEPLOY TO SYSADMIN
resource snowflake_role_grants grant_db_deploy_sysadmin {
  provider    = snowflake.securityadmin
  for_each    = toset(var.LISTE_PRODUCTEURS)
  role_name   = snowflake_role.database_deploy[each.key].name
  roles       = ["SYSADMIN"]
}
