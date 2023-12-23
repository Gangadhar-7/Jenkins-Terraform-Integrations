terraform {
  backend "s3" {
    bucket = "jenkins-terraform-integration-bckt"
    key = "main"
    region = "us-east-1"
    dynamodb_table = "jenkins-terraform-integration-table"
  }
}
