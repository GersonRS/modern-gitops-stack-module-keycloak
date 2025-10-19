locals {
  helm_values = [{
    keycloak = {
      name     = "keycloak"
      replicas = var.replicas
      database = {
        host     = var.database.host
        username = base64encode(var.database.username)
        password = base64encode(var.database.password)
      }
      serviceMonitor = {
        enabled = var.enable_service_monitor
      }
      ingress = {
        enabled = true
        annotations = {
          "cert-manager.io/cluster-issuer"                   = "${var.cluster_issuer}"
          "traefik.ingress.kubernetes.io/router.entrypoints" = "websecure"
          "traefik.ingress.kubernetes.io/router.tls"         = "true"
        }
        host = "keycloak.${trimprefix("${var.subdomain}", ".")}.${var.base_domain}"
        path = "/"
        tls = {
          secretName = "keycloak-tls-secret"
          host       = "keycloak.${trimprefix("${var.subdomain}", ".")}.${var.base_domain}"
        }
      }
    }
  }]
}
