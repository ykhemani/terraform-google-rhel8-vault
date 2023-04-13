# terraform-google-rhel8-vault

This repo contains a [HashiCorp](https://hashicorp.com) [Terraform](https://terraform.io) configuration for provisioning a [VPC](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network), [VM](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) and related resources required for conducting a [Vault](https://vaultproject.io) Proof of Value (POV).

## Use

### Packer Machine Image
This repo is designed to be used in conjunction with a machine image generated using the [packer-rhel8-vault](https://github.com/ykhemani/packer-rhel8-vault) repo.

### Variables
Set the following Terraform variables to run this Terraform configuration:
| Variable | Value | Type |
|----------|-------|------|
| `bastion_machine_type` | `n2-standard-4` | terraform |
| `bastion_name` | Name for bastion host | terraform |
| `cidr_ingress_https_allow` | List of CIDR's from which to allow https access | terraform |
| `cidr_ingress_ssh_allow` | List of CIDR's from which to allow ssh access | terraform |
| `cidr_ingress_vault_allow` | List of CIDR's from which to allow vault access | terraform |
| `friendly_name_prefix` | friendly naming prefix | terraform |
| `google_project_id` | Google Project ID | terraform |
| `subnet_name` | Name for subnet | terraform |
| `vpc_name` | Name for VPC | terraform |
| `GOOGLE_CREDENTIALS` | Google Credentials | env |
| `HCP_CLIENT_ID` | HCP Service Principal Client ID | env |
| `HCP_CLIENT_SECRET` | HCP Service Principal Client Secret | env |

Please create `GOOGLE_CREDENTIALS` and `HCP_CLIENT_SECRET` as sensitive variables.

---
