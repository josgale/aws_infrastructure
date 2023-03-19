resource "aws_ses_domain_mail_from" "example" {
  domain           = aws_ses_domain_identity.example.domain
  mail_from_domain = "bounce.${aws_ses_domain_identity.example.domain}"
}

# Set Domain Identity for SES
resource "aws_ses_domain_identity" "example" {
  domain = var.ses_domain
}

# Add MX record to Route53
resource "aws_route53_record" "example_ses_domain_mail_from_mx" {
  zone_id = var.hosted_zone_id
  name    = aws_ses_domain_mail_from.example.mail_from_domain
  type    = "MX"
  ttl     = "600"
  records = ["10 feedback-smtp.${var.region}.amazonses.com"] 
}

# Add SPF record to Route53
resource "aws_route53_record" "example_ses_domain_mail_from_txt" {
  zone_id = var.hosted_zone_id
  name    = aws_ses_domain_mail_from.example.mail_from_domain
  type    = "TXT"
  ttl     = "600"
  records = ["v=spf1 include:amazonses.com -all"]
}