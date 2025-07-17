output "s3_website_url" {
  description = "S3 static website endpoint"
  value       = aws_s3_bucket_website_configuration.website.website_endpoint
}

output "cloudfront_url" {
  description = "CloudFront CDN URL"
  value       = "https://${aws_cloudfront_distribution.cdn.domain_name}"
}
