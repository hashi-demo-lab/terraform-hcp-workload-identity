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
