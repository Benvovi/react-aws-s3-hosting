provider "aws" {
  region = "us-west-1"  # ✅ Matches your AWS region
}

resource "aws_s3_bucket" "static_site" {
  bucket        = "dev-frontend-benjamin-1616525050"
  force_destroy = true
}

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.static_site.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "public" {
  bucket = aws_s3_bucket.static_site.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "policy" {
  bucket = aws_s3_bucket.static_site.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "PublicReadGetObject",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.static_site.arn}/*"
      }
    ]
  })
}

resource "aws_s3_object" "upload_files" {
  for_each = {
    for file in fileset("${path.module}/site", "**/*.*") :
    file => file
    if !startswith(file, ".") && can(regex("^.*\\.([a-zA-Z0-9]+)$", file))
  }

  bucket = aws_s3_bucket.static_site.id
  key    = each.value
  source = "${path.module}/site/${each.value}"
  etag   = filemd5("${path.module}/site/${each.value}")

  content_type = lookup(
    {
      html = "text/html"
      js   = "application/javascript"
      css  = "text/css"
      png  = "image/png"
      jpg  = "image/jpeg"
      jpeg = "image/jpeg"
      svg  = "image/svg+xml"
      mp4  = "video/mp4"
    },
    lower(regex("^.*\\.([a-zA-Z0-9]+)$", each.value)[0]),
    "application/octet-stream"
  )
}
