variable "hcp_project_id" {
  description = "The HCP project ID to grant access to"
  type        = string
}

variable "workload_idp_issuer_uri" {
  description = "The expected issuer of the OIDC token that will be used to authenticate. E.g. for Terraform Cloud this is 'https://app.terraform.io'"
  type        = string
}

variable "workload_idp_allowed_audiences" {
  description = "The expected intended audience(s) of the OIDC token that will be used to authenticate."
  type        = list(string)
  default     = ["hcp.workload.identity"]
}

variable "hcp_service_principal_name" {
  description = "The name for a created service principal that your workload identity provider will use. E.g. 'terraform-cloud'"
  type = string
}

variable "workload_idp_conditional_access_expression" {
  description = "A hashicorp/go-bexpr string that is evaluated when exchanging tokens, restricting which upstream identities are allowed to access the service principal. Example: 'jwt_claims.sub matches `^organization:org-xxxx:*`' would allow all stacks to authenticate in an organization with ID org-xxxx. See subject claim documentation for stacks OIDC authentication for more information."
  type = string
}

terraform {
  required_providers {
    hcp = {
      source  = "hashicorp/hcp"
      version = "~> 0.78.0"
    }
  }
}

provider "hcp" {
  project_id = var.hcp_project_id
}

# Create a service principal for your workload identity provider (e.g. Terraform Cloud) to use
# This is a *separate* service principal from the one you're using
# to provision this configuration.
resource "hcp_service_principal" "tfc" {
  name = var.hcp_service_principal_name
}

# Give the created service principal permission to the project, to read HVS
resource "hcp_project_iam_binding" "this" {
  project_id   = var.hcp_project_id
  principal_id = hcp_service_principal.tfc.resource_id
  role         = "roles/contributor"
}

# Add a workload IDP for your service (e.g. Terraform Cloud) to use the created service principal
resource "hcp_iam_workload_identity_provider" "idp" {
  name = "my-workload-identity-provider"
  service_principal = hcp_service_principal.tfc.resource_name
  # This is broken in the HCP provider. Spaces aren't allowed!
  description       = "Allow-TFC-to-act-as-sp-for-tfc-service-principal"

  conditional_access = var.workload_idp_conditional_access_expression

  oidc = {
    issuer_uri        = var.workload_idp_issuer_uri
    allowed_audiences = var.workload_idp_allowed_audiences
  }
}

output "workload_idp_resource_name" {
  value = hcp_iam_workload_identity_provider.idp.resource_name
}
