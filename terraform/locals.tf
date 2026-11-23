locals {
  accelerator_installer_stack_template_name = "AWSAccelerator-InstallerStack.template" 
  accelerator_installer_stack_template_file = "${path.module}/lib/AWSAccelerator-InstallerStack.template"
}

locals {
  lza_installer_stack_name = var.accelerator_installer_stack_name
  lza_installer_parameters = {
    AcceleratorPrefix                  = var.accelerator_config.accelerator_prefix
    ApprovalStageNotifyEmailList       = var.accelerator_config.approval_stage_notify_email_list
    AuditAccountEmail                  = var.accelerator_config.audit_account_email
    ConfigCodeConnectionArn            = var.accelerator_config.config_codeconnection_arn
    ConfigurationRepositoryLocation    = var.accelerator_config.configuration_repository_location
    ControlTowerEnabled                = var.accelerator_config.control_tower_enabled
    EnableApprovalStage                = var.accelerator_config.enable_approval_stage
    ExistingConfigRepositoryName       = var.accelerator_config.existing_config_repository_name
    ExistingConfigRepositoryBranchName = var.accelerator_config.existing_config_repository_branch_name
    LogArchiveAccountEmail             = var.accelerator_config.log_archive_account_email
    ManagementAccountEmail             = var.accelerator_config.management_account_email
    RepositorySource                   = var.accelerator_config.repository_source
    RepositoryOwner                    = var.accelerator_config.repository_owner
    RepositoryName                     = var.accelerator_config.repository_name
    RepositoryBranchName               = var.accelerator_config.repository_branch_name
    UseExistingConfigRepo              = var.accelerator_config.use_existing_config_repo
  }
}