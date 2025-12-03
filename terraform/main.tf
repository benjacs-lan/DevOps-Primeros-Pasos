resource "aws_s3_bucket" "example_bucket" {
  bucket = "${var.project_name}-example-bucket-${random_id.bucket_suffix.hex}"

  tags = {
    Name        = "Example Bucket"
    Environment = "Dev"
    Project     = var.project_name
  }
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}
