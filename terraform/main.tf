/*
--- LZA Source Bucket ---
Holds the self-hosted LZA release source (a zipped copy of the
awslabs/landing-zone-accelerator-on-aws repo at a pinned tag).

The installer stack's RepositoryBucketName/RepositoryBucketObject
parameters point here instead of pulling from GitHub.
*/
resource "aws_s3_bucket" "lza_source_code" {
  bucket = "aws-accelerator-source-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.region}"
}

resource "aws_s3_bucket_versioning" "lza_source_code" {
  bucket = aws_s3_bucket.lza_source_code.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "lza_source_code" {
  bucket                  = aws_s3_bucket.lza_source_code.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

/*
--- LZA Installer Templates Bucket ---
Holds the installer CloudFormation templates for each pinned LZA version.
*/
resource "aws_s3_bucket" "lza_installer_templates" {
  bucket = "aws-accelerator-cf-templates-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.region}"
}

resource "aws_s3_bucket_versioning" "lza_installer_templates" {
  bucket = aws_s3_bucket.lza_installer_templates.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "lza_installer_templates" {
  bucket                  = aws_s3_bucket.lza_installer_templates.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "lza_source_code" {
  bucket = aws_s3_bucket.lza_source_code.id
  key    = "release/${var.lza_version}.zip"
  source = var.lza_source_code_zip_file
  etag   = filemd5(var.lza_source_code_zip_file)
}

resource "aws_s3_object" "lza_installer_template" {
  bucket = aws_s3_bucket.lza_installer_templates.id
  key    = "AWSAccelerator-InstallerStack-${var.lza_version}.template.json"
  source = var.lza_installer_template_file
  etag   = filemd5(var.lza_installer_template_file)
}

/*
--- AWS LZA Installer CloudFormation Stack ---
Installs the Landing Zone Accelerator pipeline (CodePipeline/CodeBuild)
in the management account, which in turn deploys landing zone components
and resources from LZA config files.
*/
resource "aws_cloudformation_stack" "lza_installer" {
  name         = "AWSAccelerator-InstallerStack"
  template_url = "https://${aws_s3_bucket.lza_installer_templates.bucket_regional_domain_name}/${aws_s3_object.lza_installer_template.key}"

  parameters = {
    "RepositorySource"                = "s3"
    "RepositoryBucketName"            = aws_s3_bucket.lza_source_code.id
    "RepositoryBucketObject"          = aws_s3_object.lza_source_code.key
    "ConfigurationRepositoryLocation" = "s3"
    "UseExistingConfigRepo"           = var.accelerator_config.use_existing_config_repo
    "EnableApprovalStage"             = var.accelerator_config.enable_approval_stage
    "ApprovalStageNotifyEmailList"    = var.accelerator_config.approval_stage_notify_email_list
    "ManagementAccountEmail"          = var.accelerator_config.management_account_email
    "LogArchiveAccountEmail"          = var.accelerator_config.log_archive_account_email
    "AuditAccountEmail"               = var.accelerator_config.audit_account_email
    "ControlTowerEnabled"             = var.accelerator_config.control_tower_enabled
    "AcceleratorPrefix"               = var.accelerator_config.accelerator_prefix
  }

  disable_rollback = false
  capabilities = [
    "CAPABILITY_IAM"
  ]
}

/*
--- LZA Pipeline Trigger Role ---
Standing federated role assumed by GitHub Actions (OIDC, no long-lived credentials)
to push landing zone config changes and trigger the accelerator's CodePipeline.
*/
resource "aws_iam_role" "lza_trigger_role" {
  name = "AWSAccelerator-PipelineTriggerRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::907480720489:oidc-provider/token.actions.githubusercontent.com"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
            "token.actions.githubusercontent.com:sub" = "repo:ilysiumdotdev@203716773/aws-control-tower-landing-zone@1301827889:environment:landing-zone"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "lza_config_access" {
  name = "AWSAccelerator-PipelineTriggerRolePolicy"
  role = aws_iam_role.lza_trigger_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "UploadAcceleratorConfig",
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:GetObject"
        ],
        Resource = "arn:aws:s3:::aws-accelerator-config-907480720489-us-east-2/zipped/*"
      },
      {
        Sid    = "ListAcceleratorConfigBucket",
        Effect = "Allow",
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ],
        Resource = "arn:aws:s3:::aws-accelerator-config-907480720489-us-east-2"
      },
      {
        Sid    = "DecryptBucketKmsKey",
        Effect = "Allow",
        Action = [
          "kms:GenerateDataKey",
          "kms:Decrypt"
        ],
        Resource = "arn:aws:kms:us-east-2:907480720489:key/988c7f8c-1403-44a1-a8bc-cc6e2aa40d96"
      },
      {
        Sid    = "TriggerAcceleratorPipeline",
        Effect = "Allow",
        Action = [
          "codepipeline:StartPipelineExecution",
          "codepipeline:GetPipelineState",
          "codepipeline:GetPipelineExecution"
        ],
        Resource = "arn:aws:codepipeline:us-east-2:907480720489:AWSAccelerator-Pipeline"
      }
    ]
  })
}
