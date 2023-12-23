terraform {
  backend "s3" {
    bucket = "jenkins-terraform-integration-bckt"
    key = "main"
    region = "us-east-1"
  }
}
