output "oai_id" {
  value = try(aws_cloudfront_origin_access_identity.vss[0].id, "")
}
output "oai_caller_reference" {
  value = try(aws_cloudfront_origin_access_identity.vss[0].caller_reference, "")
}
output "oai_cloudfront_access_identity_path" {
  value = try(aws_cloudfront_origin_access_identity.vss[0].cloudfront_access_identity_path, "")
}
output "oai_etag" {
  value = try(aws_cloudfront_origin_access_identity.vss[0].etag, "")
}
output "oai_iam_arn" {
  value = try(aws_cloudfront_origin_access_identity.vss[0].iam_arn, "")
}
output "oai_s3_canonical_user_id" {
  value = try(aws_cloudfront_origin_access_identity.vss[0].s3_canonical_user_id, "")
}

output "cf_func_arn" {
  value = try(aws_cloudfront_function.vss[0].arn, "")
}

output "cf_id" {
  value = try(aws_cloudfront_distribution.vss[0].id, "")
}
output "cf_arn" {
  value = try(aws_cloudfront_distribution.vss[0].arn, "")
}
output "cf_caller_reference" {
  value = try(aws_cloudfront_distribution.vss[0].caller_reference, "")
}
output "cf_status" {
  value = try(aws_cloudfront_distribution.vss[0].status, "")
}
output "cf_domain_name" {
  value = try(aws_cloudfront_distribution.vss[0].domain_name, "")
}
output "cf_last_modified_time" {
  value = try(aws_cloudfront_distribution.vss[0].last_modified_time, "")
}
output "cf_etag" {
  value = try(aws_cloudfront_distribution.vss[0].etag, "")
}
output "cf_hosted_zone_id" {
  value = try(aws_cloudfront_distribution.vss[0].hosted_zone_id, "")
}
output "cf_key_group_id" {
  value = try(aws_cloudfront_key_group.vss[0].id, "")
}