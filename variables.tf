variable "hcp_project_id" {
  description = "The HCP project ID to grant access to"
  type        = string
}

variable "workload_idp_issuer_uri" {
  description = "The expected issuer of the OIDC token that will be used to authenticate. E.g. for Terraform Cloud this is 'https://app.terraform.io'"
  type        = string
  default = "https://app.terraform.io"
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