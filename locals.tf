locals {
  helm_values = [{
    keycloak = {
      name = "keycloak"
      # Database creds are shown in tfm plan.
      # TODO manage this. Proposal: create namespace and secret before app.
      database = {
        host     = var.database.host
        username = var.database.username
        password = var.database.password
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
        hosts = [
          {
            host = "keycloak.${trimprefix("${var.subdomain}.${var.base_domain}", ".")}"
            path = "/"
          },
          {
            host = "keycloak.${trimprefix("${var.subdomain}.${var.cluster_name}", ".")}.${var.base_domain}"
            path = "/"
          },
        ]
        tls = [{
          secretName = "keycloak-tls"
          hosts = [
            "keycloak.${trimprefix("${var.subdomain}.${var.base_domain}", ".")}",
            "keycloak.${trimprefix("${var.subdomain}.${var.cluster_name}", ".")}.${var.base_domain}"
          ]
        }]
      }
    }
  }]
}
