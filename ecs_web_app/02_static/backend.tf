terraform {
 backend "s3" {
   encrypt = true
   bucket = "PROJECT-terraform-state"
   key = "PROJECT/terraform.tfstate"
   dynamodb_table = "PROJECT_terraform_lock"
   region = var.aws_region
 }
}
