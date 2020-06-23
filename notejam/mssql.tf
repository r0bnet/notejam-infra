resource "azurerm_resource_group" "mssql_rg" {
  count    = length(local.locations)
  name     = "${var.prefix}-mssql${count.index + 1}-rg"
  location = element(local.locations, count.index)
}

resource "random_string" "mssql_admin_password" {
  count   = length(local.locations)
  length  = 16
  special = false
}

resource "azurerm_mssql_server" "mssql" {
  count                        = length(local.locations)
  name                         = "${var.prefix}-mssql${count.index + 1}"
  resource_group_name          = element(azurerm_resource_group.mssql_rg.*, count.index).name
  location                     = element(local.locations, count.index)
  version                      = "12.0"
  administrator_login          = "mssql_admin"
  administrator_login_password = element(random_string.mssql_admin_password.*, count.index).result
}

resource "azurerm_sql_virtual_network_rule" "k8s" {
  count               = length(local.locations)
  name                = "k8s"
  resource_group_name = element(azurerm_resource_group.mssql_rg.*, count.index).name
  server_name         = element(azurerm_mssql_server.mssql.*, count.index).name
  subnet_id           = element(azurerm_subnet.k8s.*, count.index).id
}

resource "azurerm_mssql_database" "notejam" {
  count          = length(local.locations)
  name           = "notejam"
  server_id      = element(azurerm_mssql_server.mssql.*, count.index).id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = var.mssql_db_max_size_gb
  sku_name       = var.mssql_db_sku
  zone_redundant = true
}
