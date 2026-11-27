variable "lza_version" {
  type        = string
  description = "Version of the AWS Landing Zone Accelerator."
}

variable "lza_source_code_zip_file" {
  type        = string
  description = "Path to the zip file containing the LZA source code."
}

variable "lza_installer_template_file" {
  type        = string
  description = "Path to the LZA installer CloudFormation template file."
}

variable "accelerator_config" {
  type = object({
    accelerator_prefix                = string
    approval_stage_notify_email_list  = string
    audit_account_email               = string
    control_tower_enabled             = string
    enable_approval_stage             = string
    log_archive_account_email         = string
    management_account_email          = string
  })
  description = "Configuration for the AWS Landing Zone Accelerator Installer stack."
}
