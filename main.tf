module "notejam" {
  source = "./notejam"

  prefix             = var.prefix
  primary_location   = var.primary_location
  secondary_location = var.secondary_location

  mssql_db_sku         = var.mssql_db_sku
  mssql_db_max_size_gb = var.mssql_db_max_size_gb
}
