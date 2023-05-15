resource "aws_cloudfront_distribution" "example" {
  comment = var.cloudFrontComment

  origin {
    domain_name = "${var.bucketName}.s3-website.eu-central-1.amazonaws.com"
    origin_id   = "S3-${var.bucketName}"

    custom_origin_config {
      http_port = 80
      https_port = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = var.cloudFrontDefaultRootObject

  aliases = ["baevsociety.com", "www.baevsociety.com"]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${var.bucketName}"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl           = 3600
    max_ttl               = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }
  viewer_certificate {
    acm_certificate_arn = var.certificateArn
    ssl_support_method   = "sni-only"
    minimum_protocol_version = var.cloudFrontCertificateVersion
  }
}

resource "aws_route53_record" "baevsociety_com" {
  zone_id = var.hostedZoneId
  name    = "baevsociety.com"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.example.domain_name
    zone_id                = aws_cloudfront_distribution.example.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "www_baevsociety_com" {
  zone_id = var.hostedZoneId
  name    = "www.baevsociety.com"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.example.domain_name
    zone_id                = aws_cloudfront_distribution.example.hosted_zone_id
    evaluate_target_health = false
  }
}
