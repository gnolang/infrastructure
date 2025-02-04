
data "aws_backup_vault" "gno_vault" {
  name = "testnet-data-vault"
}

data "aws_iam_role" "eks_gno_backup" {
  name = "eksBackupEbsRole"
}

resource "aws_backup_plan" "testnet-backup" {
  name = "testnets_backup_plan"

  rule {
    rule_name         = "testnet-backup-rule"
    target_vault_name = data.aws_backup_vault.gno_vault.name
    schedule          = "cron(0 4 * * ? *)"

    start_window = 60
    completion_window = 120
    lifecycle {
      cold_storage_after = 10
      delete_after = 100
    }
  }
}

resource "aws_backup_selection" "ebs_tagged_resources" {
  name         = "testnets_backup_selection"
  iam_role_arn = data.aws_iam_role.eks_gno_backup.arn
  plan_id      = aws_backup_plan.testnet-backup.id
  resources    = ["arn:aws:ec2:*:*:volume/*"]

  condition {
    string_equals {
      key   = "aws:ResourceTag/Name"
      value = "validator-storage"
    }
    string_equals {
      key   = "aws:ResourceTag/Name"
      value = "validator-storage"
    }
  }

  depends_on = [ aws_backup_plan.testnet-backup ]
}
