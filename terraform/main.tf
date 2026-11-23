/*
--- LZA CloudFormation Templates Bucket ---
Stores CloudFormation templates used to deploy the LZA pipeline. 
*/
data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "lza_installer_templates" {
  bucket = "aws-accelerator-cf-templates-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.region}"
}

resource "aws_s3_bucket_versioning" "lza_installer_templates" {
  bucket = aws_s3_bucket.lza_installer_templates.id
  versioning_configuration {
    status = "Enabled"
  }
}

/*
--- AWS LZA Installer CloudFormation Stack ---
Installs AWS Landing Zone Accelerator pipeline resources in the management account
to deploy landing zone components and controls.
*/
resource "aws_s3_object" "lza_installer_template" {
  bucket  = aws_s3_bucket.lza_installer_templates.id
  key     = local.accelerator_installer_stack_template_name
  source  = local.accelerator_installer_stack_template_file
  etag    = filemd5(local.accelerator_installer_stack_template_file)
}

resource "aws_cloudformation_stack" "lza_installer" {
  name          = local.lza_installer_stack_name
  parameters    = local.lza_installer_parameters
  template_url  = "https://${aws_s3_bucket.cfn_templates.bucket_regional_domain_name}/${aws_s3_object.lza_installer_template.key}" 

  disable_rollback = false
  capabilities = [
    "CAPABILITY_IAM"
  ]
}

/*
--- LZA Pipeline Trigger Role ---
Federated IAM Role with permissions to upload landing zone config
and trigger the accelerator pipeline.
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
  name = "AcceleratorConfigAccess"
  role = aws_iam_role.lza_trigger_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::aws-accelerator-config-907480720489-us-east-2",
          "arn:aws:s3:::aws-accelerator-config-907480720489-us-east-2/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy" "lza_pipeline_trigger" {
  name = "AcceleratorPipelineTrigger"
  role = aws_iam_role.lza_trigger_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "codepipeline:GetPipeline",
				  "codepipeline:GetPipelineState",
          "codepipeline:GetPipelineExecution",
          "codepipeline:ListPipelineExecutions",
          "codepipeline:StartPipelineExecution"
        ]
        Resource = "arn:aws:codepipeline:us-east-2:907480720489:AWSAccelerator-Pipeline"
      }
    ]
  })
}