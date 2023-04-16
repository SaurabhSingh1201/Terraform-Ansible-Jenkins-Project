resource "aws_s3_bucket" "Saurabh_bucket" {
  bucket = "my-tf-test-bucket1201"
  acl = "private"

  versioning {
    enabled = true
  }

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}