variable "accelerator_installer_stack_name" {
  type        = string
  description = "Name of the AWS Accelerator Installer Cloudformation Stack."
}

variable "accelerator_config" {
  type = object({
    accelerator_prefix                     = optional(string, "AWSAccelerator")
    approval_stage_notify_email_list       = optional(string, "")
    audit_account_email                    = string
    config_codeconnection_arn              = optional(string, "")
    configuration_repository_location      = optional(string, "s3")
    control_tower_enabled                  = optional(string, "Yes")
    enable_approval_stage                  = optional(string, "Yes")
    existing_config_repository_branch_name = optional(string, "")
    existing_config_repository_name        = optional(string, "")
    existing_config_repository_owner       = optional(string, "")
    log_archive_account_email              = string
    management_account_email               = string
    repository_branch_name                 = string
    repository_name                        = optional(string, "landing-zone-accelerator-on-aws")
    repository_owner                       = optional(string, "awslabs")
    repository_source                      = optional(string, "github")
    use_existing_config_repo               = optional(string, "No")
  })
  description = "Configuration for the AWS Landing Zone Accelerator Installer stack."
}
