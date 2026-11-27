/*
--- AWS Landing Zone Accelerator Config Parameters ---
*/
accelerator_config = {
  use_existing_config_repo         = "No"
  enable_approval_stage            = "Yes"
  approval_stage_notify_email_list = "platform@ilysium.io,security@ilysium.io"
  management_account_email         = "aws+management@ilysium.io"
  log_archive_account_email        = "aws+log-archive@ilysium.io"
  audit_account_email              = "aws+audit@ilysium.io"
  control_tower_enabled            = "Yes"
  accelerator_prefix               = "AWSAccelerator"
}