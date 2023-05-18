provider "aws" {
  region = "us-east-1"
  alias  = "east"
}

resource "aws_acm_certificate" "example" {
  provider = aws.east
  domain_name               = "baevsociety.com"
  subject_alternative_names = ["www.baevsociety.com"]
  validation_method         = "DNS"
}

resource "aws_route53_record" "example" {
  for_each = {
    for dvo in aws_acm_certificate.example.domain_validation_options : dvo.domain_name => {
      name    = dvo.resource_record_name
      record  = dvo.resource_record_value
      type    = dvo.resource_record_type
      zone_id = "Z0637605ZR276D7FVLBB"
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 300
  type            = each.value.type
  zone_id         = each.value.zone_id
}

#resource "aws_acm_certificate_validation" "example" {
#  certificate_arn         = aws_acm_certificate.example.arn
#  validation_record_fqdns = [for record in aws_route53_record.example : record.fqdn]
#}
