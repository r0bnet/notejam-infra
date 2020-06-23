resource "azurerm_resource_group" "frontdoor_rg" {
  name     = "${var.prefix}-frontdoor-rg"
  location = var.primary_location
}

resource "azurerm_frontdoor" "frontdoor" {
  name                                         = "${var.prefix}-frontdoor"
  resource_group_name                          = azurerm_resource_group.frontdoor_rg.name
  enforce_backend_pools_certificate_name_check = false

  frontend_endpoint {
    name                              = "frontend-endpoint"
    host_name                         = "${var.prefix}-notejam.azurefd.net"
    custom_https_provisioning_enabled = false
  }

  backend_pool {
    name = "notejam-pool"

    backend {
      address     = element(azurerm_public_ip.appgw, 0).ip_address
      host_header = "notejam1.nordcloud.com"
      http_port   = 80
      https_port  = 443
      priority    = 1
    }

    backend {
      address     = element(azurerm_public_ip.appgw, 1).ip_address
      host_header = "notejam2.nordcloud.com"
      http_port   = 80
      https_port  = 443
      priority    = 2
    }

    health_probe_name   = "notejam-healthprobe"
    load_balancing_name = "notejam-lb"
  }

  backend_pool_health_probe {
    name    = "notejam-healthprobe"
    enabled = false
  }

  backend_pool_load_balancing {
    name = "notejam-lb"
  }

  routing_rule {
    name               = "notejam-rule"
    accepted_protocols = ["Http", "Https"]
    patterns_to_match  = ["/*"]
    frontend_endpoints = ["frontend-endpoint"]
    forwarding_configuration {
      forwarding_protocol = "MatchRequest"
      backend_pool_name   = "notejam-pool"
    }
  }
}
