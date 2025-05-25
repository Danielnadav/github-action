provider "helm" {
  kubernetes {
    config_path = "~/.kube/config" # Or use kubeconfig from EKS output
  }
}

resource "kubernetes_secret" "github_token" {
  metadata {
    name      = "github-auth-secret"
    namespace = "actions-runner-system"
  }

  data = {
    github_token = base64encode(var.github_token)
  }

  type = "Opaque"
}
variable "github_token" {
  description = "GitHub personal access token"
  type        = string
  sensitive   = true
  default = "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"
}
resource "helm_release" "arc" {
  name       = "arc"
  namespace  = "actions-runner-system"
  chart      = "actions-runner-controller"
  repository = "https://actions-runner-controller.github.io/actions-runner-controller"
  version    = "0.23.3" # check for latest

  create_namespace = true

  set {
    name  = "controllerManager.runnerGitHubUrl"
    value = "https://github.com/Danielnadav/github-action"
  }

  set {
    name  = "controllerManager.githubToken.valueFromSecret.name"
    value = kubernetes_secret.github_token.metadata[0].name
  }

  set {
    name  = "controllerManager.githubToken.valueFromSecret.key"
    value = ""
  }

  set {
    name  = "githubWebhookServer.enabled"
    value = "true"
  }
}

# resource "kubernetes_manifest" "runner_deployment" {
#   manifest = {
#     apiVersion = "actions.summerwind.dev/v1alpha1"
#     kind       = "RunnerDeployment"
#     metadata = {
#       name      = "my-runner"
#       namespace = "actions-runner-system"
#     }
#     spec = {
#       replicas = 2
#       template = {
#         spec = {
#           repository = "https://github.com/Danielnadav/github-action"
#           labels     = ["self-hosted", "linux", "docker"]
#           resources = {
#             limits = {
#               cpu    = "500m"
#               memory = "1Gi"
#             }
#             requests = {
#               cpu    = "250m"
#               memory = "512Mi"
#             }
#           }
#         }
#       }
#     }
#   }
# }
