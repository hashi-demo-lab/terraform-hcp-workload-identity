# terraform-hcp-workload-identity

A Terraform module that uses the [HCP Provider for Terraform](https://registry.terraform.io/providers/hashicorp/hcp/latest/docs) to configure workload identity (OIDC auth) in HashiCorp Cloud Platform. With
this, you can configure OIDC authentication with Terraform Cloud or any other workload identity
provider.

As of this writing, configuring via the API/Terraform like this is the _only_ way to configure
workload identity with HCP - there's no UI yet.

## Prerequisites

You must have access to [HashiCorp Cloud Platform (HCP)](https://www.hashicorp.com/cloud-platform/).
Create an HCP [service principal](https://registry.terraform.io/providers/hashicorp/hcp/latest/docs/guides/auth) for your _organization_ (not project).
