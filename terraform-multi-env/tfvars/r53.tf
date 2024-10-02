resource "aws_route53_record" "project" {
  for_each = aws_instance.expense
  zone_id = var.zone_id
  name    = each.key == "frontend-prod" ? var.domain_name : "${each.key}.${var.domain_name}"
  type    = "A"
  ttl     = 1
  records = startswith(each.key, "frontend") ? [each.value.public_ip] : [each.value.private_ip]
  # if records already exists
  allow_overwrite = true
}