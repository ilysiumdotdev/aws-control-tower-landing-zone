/*
--- AWS Landing Zone Accelerator Config Parameters ---
*/
accelerator_installer_stack_name = "AWSAccelerator-InstallerStack"

accelerator_config = {
  repository_source      = "github"
  repository_owner       = "awslabs"
  repository_name        = "landing-zone-accelerator-on-aws"
  repository_branch_name = "release/v1.17.1"

  enable_approval_stage            = "Yes"
  approval_stage_notify_email_list = "platform@ilysium.io,security@ilysium.io"
  management_account_email         = "aws+management@ilysium.io"
  log_archive_account_email        = "aws+log-archive@ilysium.io"
  audit_account_email              = "aws+audit@ilysium.io"
  control_tower_enabled            = "Yes"

  configuration_repository_location = "s3"
  use_existing_config_repo          = "No"
}