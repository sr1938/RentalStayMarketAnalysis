resource "aws_s3_bucket" "group4" {
  bucket = "group4bucket12"
#   acl    = "public-read-write"  # You can set the ACL as per your requirements

  # Optionally, you can add tags to your S3 bucket
  tags = {
    Name        = "MyGroup4Bucket12"
    Environment = "Test"
    Project     = var.project
  }
}
