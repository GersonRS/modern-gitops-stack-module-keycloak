locals {
  helm_values = [{
    keycloak = {
      name     = "keycloak"
      replicas = var.replicas
      database = var.database != null ? {
        create   = false
        host     = var.database.host
        username = base64encode(var.database.username)
        password = base64encode(var.database.password)
        } : {
        # TODO doc that the fallback map (experimental ephemeral postgresql server) should never be used in production.
        create   = true
        host     = "keycloak-postgres-db"
        username = base64encode("postgres")
        password = base64encode(random_password.db_password.0.result)
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
