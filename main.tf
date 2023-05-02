# Configure the AzureRM provider
terraform {
  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      #version = "0.1.0" # You can use a different version if needed
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      #version = "~> 2.0"
    }
  }
}
provider "azurerm" {
  features {}
}

# Retrieve Snowflake credentials from Azure Key Vault
data "azurerm_key_vault" "example" {
  name                = "kv-atholmes"
  resource_group_name = "rg-ah_keyvault"
}

data "azurerm_key_vault_secret" "snowflake_password" {
  name         = "snowflake-password"
  key_vault_id = data.azurerm_key_vault.example.id
}

# Configure the Snowflake provider using the retrieved secrets
provider "snowflake" {
  account  = "noefgcv-jv58472"
  username = "andy"
  password = data.azurerm_key_vault_secret.snowflake_password.value
}

# Create a Snowflake database
resource "snowflake_database" "example" {
  name = "example_db"
  comment = "Example database created by Terraform"
}

# Create a Snowflake warehouse
resource "snowflake_warehouse" "example" {
  name = "example_wh"
  warehouse_size = "X-SMALL"
  auto_suspend = 60
  auto_resume = true
  initially_suspended = true
  comment = "Example warehouse created by Terraform"
}

# Output the database and warehouse names
output "database_name" {
  value = snowflake_database.example.name
}

output "warehouse_name" {
  value = snowflake_warehouse.example.name
}

resource "snowflake_schema" "test_schema" {
  database = snowflake_database.example.name
  name     = "test_schema"
}

output "schema_name" {
  value = snowflake_schema.test_schema.name
}

resource "snowflake_table" "test_table" {
  database = snowflake_database.example.name
  schema   = snowflake_schema.test_schema.name
  name     = "test_table"

  column {
    name = "column1"
    type = "VARCHAR"
  }
  column {
    name = "column2"
    type = "INTEGER"
  }

    column {
    name = "column3"
    type = "INTEGER"
  }
}

output "table_name" {
  value = snowflake_table.test_table.name
}