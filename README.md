# Terraform AWS CloudFront Module

A versatile, production-ready Terraform module for provisioning and managing Amazon CloudFront distributions, Origin Access Identities (OAI), CloudFront Functions, Public Keys, and Key Groups.

## Features

- **S3 & Custom Origin Support**: Easily switch between standard S3 REST API endpoints (with OAC/OAI), S3 static website hosting, or custom HTTP/HTTPS endpoints.
- **Security & Access Control**: Native support for Origin Access Identity (OAI), Origin Access Control (OAC), and Signed URLs/Cookies via Public Keys & Key Groups.
- **Edge Computing Integration**: Attach CloudFront Functions or Lambda@Edge functions to request/response viewer or origin events.
- **Custom Error Handling**: Configure custom error responses (e.g., SPA `index.html` fallback for 404s).
- **Geographic Restrictions**: Easily whitelist or blacklist traffic by ISO country codes.
- **Custom Domains & SSL/TLS**: Support for ACM SSL certificates and customizable TLS protocol policies.

---

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | `>= 1.0` |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | `>= 5.0` |

---

## Usage Examples

### Example 1: Standard S3 Origin Distribution with Origin Access Control (OAC)

```hcl
module "cloudfront" {
  source = "git::https://github.com/virsas/terraform-aws-cf.git?ref=v1.0.0"

  create_cf         = true
  cf_enabled        = true
  cf_endpoint       = aws_s3_bucket.website.bucket_regional_domain_name
  cf_source_domain  = aws_s3_bucket.website.id
  cf_default_root_object = "index.html"

  # S3 REST API Endpoint with OAC
  cf_s3_config_enabled     = true
  cf_custom_config_enabled = false
  cf_oac                  = aws_cloudfront_origin_access_control.oac.id

  # Domain & SSL
  cf_source_domain_aliases     = ["app.example.com"]
  cf_ssl_acm_certificate_arn   = "arn:aws:acm:us-east-1:123456789012:certificate/abc-123"
  cf_protocol_policy           = "redirect-to-https"

  # Custom Error Responses (SPA routing)
  cf_custom_errors = [
    {
      error_code    = 404
      response_code = 200
      response_page = "/index.html"
    }
  ]
}
```

### Example 2: Custom Origin Distribution (e.g., S3 Static Website or Application Load Balancer)

```hcl
module "cloudfront_custom_origin" {
  source = "git::https://github.com/virsas/terraform-aws-cf.git?ref=v1.0.0"

  create_cf         = true
  cf_enabled        = true
  cf_endpoint       = aws_s3_bucket_website_configuration.site.website_endpoint
  cf_source_domain  = "my-custom-website-origin"
  cf_default_root_object = ""

  # Custom Origin Configuration
  cf_s3_config_enabled               = false
  cf_custom_config_enabled           = true
  cf_custom_endpoint_http_port       = 80
  cf_custom_endpoint_https_port      = 443
  cf_custom_endpoint_protocol_policy = "http-only"
  cf_custom_endpoint_ssl_protocols   = ["TLSv1.2"]

  # Domain & SSL Configuration
  cf_source_domain_aliases   = ["site.example.com"]
  cf_ssl_acm_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/abc-123"
}
```

### Example 3: Creating a CloudFront Function and Access Key Group

```hcl
module "cloudfront_with_func_and_keys" {
  source = "git::https://github.com/virsas/terraform-aws-cf.git?ref=v1.0.0"

  # Create CloudFront Function
  create_cf_func    = true
  cf_func_name      = "redirect-handler"
  cf_func_file_path = "./js/cf"

  # Create Public Key and Key Group
  create_cf_public_key = true
  cf_public_key_name   = "my-app-key"
  cf_public_key_path   = "./keys/cf"

  # Create Distribution and associate resources
  create_cf         = true
  cf_enabled        = true
  cf_endpoint       = aws_s3_bucket.assets.bucket_regional_domain_name
  cf_source_domain  = aws_s3_bucket.assets.id

  cf_function_associations = [
    {
      event_type   = "viewer-request"
      function_arn = module.cloudfront_with_func_and_keys.cf_func_arn
    }
  ]

  cf_key_group_id = module.cloudfront_with_func_and_keys.cf_key_group_id
}
```

---

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_cf"></a> [create\_cf](#input\_create\_cf) | Controls whether to create the CloudFront distribution. | `bool` | `false` | no |
| <a name="input_cf_enabled"></a> [cf\_enabled](#input\_cf\_enabled) | Controls whether the CloudFront distribution is enabled to accept user requests. | `bool` | `true` | no |
| <a name="input_cf_endpoint"></a> [cf\_endpoint](#input\_cf\_endpoint) | Domain name of the origin server (e.g. S3 bucket domain or server hostname). | `string` | `""` | no |
| <a name="input_cf_source_domain"></a> [cf\_source\_domain](#input\_cf\_source\_domain) | Unique identifier for the origin target. Required when creating a distribution. | `string` | `""` | no |
| <a name="input_cf_source_domain_aliases"></a> [cf\_source\_domain\_aliases](#input\_cf\_source\_domain\_aliases) | List of CNAME aliases (alternate domain names) for the distribution. | `list(string)` | `[]` | no |
| <a name="input_create_oai"></a> [create\_oai](#input\_create\_oai) | Controls whether to create a new Origin Access Identity (OAI). | `bool` | `false` | no |
| <a name="input_oai_description"></a> [oai\_description](#input\_oai\_description) | Description comment for the Origin Access Identity. | `string` | `"Origin Access Identity for CloudFront distribution"` | no |
| <a name="input_cf_oai"></a> [cf\_oai](#input\_cf\_oai) | ID of an existing Origin Access Identity to attach to the S3 origin. | `string` | `""` | no |
| <a name="input_cf_oac"></a> [cf\_oac](#input\_cf\_oac) | ID of an existing Origin Access Control (OAC) to attach to the S3 origin. | `string` | `""` | no |
| <a name="input_cf_s3_config_enabled"></a> [cf\_s3\_config\_enabled](#input\_cf\_s3\_config\_enabled) | Set to true for S3 REST API endpoints using OAI/OAC. | `bool` | `true` | no |
| <a name="input_cf_custom_config_enabled"></a> [cf\_custom\_config\_enabled](#input\_cf\_custom\_config\_enabled) | Set to true for custom origins or S3 website endpoints. | `bool` | `false` | no |
| <a name="input_cf_default_root_object"></a> [cf\_default\_root\_object](#input\_cf\_default\_root\_object) | Default root object (e.g. `index.html`). Leave empty for S3 website endpoints. | `string` | `"index.html"` | no |
| <a name="input_cf_origin_connection_attempts"></a> [cf\_origin\_connection\_attempts](#input\_cf\_origin\_connection\_attempts) | Number of connection attempts to origin (1 to 3). | `number` | `3` | no |
| <a name="input_cf_origin_connection_timeout"></a> [cf\_origin\_connection\_timeout](#input\_cf\_origin\_connection\_timeout) | Seconds CloudFront waits to connect to origin (1 to 10). | `number` | `10` | no |
| <a name="input_cf_origin_custom_header"></a> [cf\_origin\_custom\_header](#input\_cf\_origin\_custom\_header) | List of custom headers (`[{name = "X", value = "Y"}]`) sent to origin. | `list(object)` | `[]` | no |
| <a name="input_cf_custom_endpoint_http_port"></a> [cf\_custom\_endpoint\_http\_port](#input\_cf\_custom\_endpoint\_http\_port) | HTTP port for custom origin. | `number` | `80` | no |
| <a name="input_cf_custom_endpoint_https_port"></a> [cf\_custom\_endpoint\_https\_port](#input\_cf\_custom\_endpoint\_https\_port) | HTTPS port for custom origin. | `number` | `443` | no |
| <a name="input_cf_custom_endpoint_protocol_policy"></a> [cf\_custom\_endpoint\_protocol\_policy](#input\_cf\_custom\_endpoint\_protocol\_policy) | Protocol policy for custom origin (`http-only`, `match-viewer`, `https-only`). | `string` | `"http-only"` | no |
| <a name="input_cf_custom_endpoint_ssl_protocols"></a> [cf\_custom\_endpoint\_ssl\_protocols](#input\_cf\_custom\_endpoint\_ssl\_protocols) | SSL/TLS protocols allowed for custom origin. | `list(string)` | `["TLSv1.2"]` | no |
| <a name="input_cf_allowed_methods"></a> [cf\_allowed\_methods](#input\_cf\_allowed\_methods) | Allowed HTTP methods for default cache behavior. | `list(string)` | `["GET", "HEAD", "OPTIONS"]` | no |
| <a name="input_cf_cache_policy_id"></a> [cf\_cache\_policy\_id](#input\_cf\_cache\_policy\_id) | Unique ID of attached cache policy (default: `CachingOptimized`). | `string` | `"4135ea2d-6df8-44a3-9df3-4b5a84be39ad"` | no |
| <a name="input_cf_compress"></a> [cf\_compress](#input\_cf\_compress) | Controls automatic content compression (gzip / brotli). | `bool` | `true` | no |
| <a name="input_cf_protocol_policy"></a> [cf\_protocol\_policy](#input\_cf\_protocol\_policy) | Viewer protocol policy (`allow-all`, `https-only`, `redirect-to-https`). | `string` | `"redirect-to-https"` | no |
| <a name="input_cf_default_ttl"></a> [cf\_default\_ttl](#input\_cf\_default\_ttl) | Default TTL for cached objects (in seconds). | `number` | `0` | no |
| <a name="input_cf_min_ttl"></a> [cf\_min\_ttl](#input\_cf\_min\_ttl) | Minimum TTL for cached objects (in seconds). | `number` | `0` | no |
| <a name="input_cf_max_ttl"></a> [cf\_max\_ttl](#input\_cf\_max\_ttl) | Maximum TTL for cached objects (in seconds). | `number` | `0` | no |
| <a name="input_cf_key_group_id"></a> [cf\_key\_group\_id](#input\_cf\_key\_group\_id) | ID of CloudFront key group for signed URLs/cookies. | `string` | `""` | no |
| <a name="input_cf_function_associations"></a> [cf\_function\_associations](#input\_cf\_function\_associations) | List of CloudFront Function associations. | `list(object)` | `[]` | no |
| <a name="input_cf_lambda_functions"></a> [cf\_lambda\_functions](#input\_cf\_lambda\_functions) | List of Lambda@Edge function associations. | `list(object)` | `[]` | no |
| <a name="input_create_cf_func"></a> [create\_cf\_func](#input\_create\_cf\_func) | Controls whether to create a CloudFront Function. | `bool` | `false` | no |
| <a name="input_cf_func_name"></a> [cf\_func\_name](#input\_cf\_func\_name) | Name of CloudFront Function and JavaScript file (`{name}.js`). | `string` | `""` | no |
| <a name="input_cf_func_file_path"></a> [cf\_func\_file\_path](#input\_cf\_func\_file\_path) | Local path containing CloudFront Function JS file. | `string` | `"./js/cf"` | no |
| <a name="input_cf_func_runtime"></a> [cf\_func\_runtime](#input\_cf\_func\_runtime) | CloudFront Function runtime environment. | `string` | `"cloudfront-js-2.0"` | no |
| <a name="input_cf_func_publish"></a> [cf\_func\_publish](#input\_cf\_func\_publish) | Controls whether to publish CloudFront Function immediately. | `bool` | `true` | no |
| <a name="input_create_cf_public_key"></a> [create\_cf\_public\_key](#input\_create\_cf\_public\_key) | Controls whether to create a CloudFront Public Key & Key Group. | `bool` | `false` | no |
| <a name="input_cf_public_key_name"></a> [cf\_public\_key\_name](#input\_cf\_public\_key\_name) | Public key identifier name and PEM file name (`{name}.pem`). | `string` | `""` | no |
| <a name="input_cf_public_key_path"></a> [cf\_public\_key\_path](#input\_cf\_public\_key\_path) | Local directory containing public key PEM file. | `string` | `"./keys/cf"` | no |
| <a name="input_cf_ipv6_enabled"></a> [cf\_ipv6\_enabled](#input\_cf\_ipv6\_enabled) | Controls whether IPv6 is enabled on distribution. | `bool` | `false` | no |
| <a name="input_cf_http_version"></a> [cf\_http\_version](#input\_cf\_http\_version) | Maximum HTTP version (`http1.1`, `http2`, `http2and3`, `http3`). | `string` | `"http2"` | no |
| <a name="input_cf_custom_errors"></a> [cf\_custom\_errors](#input\_cf\_custom\_errors) | Custom HTTP error response configurations. | `list(object)` | `[]` | no |
| <a name="input_cf_geo_restriction_locations"></a> [cf\_geo\_restriction\_locations](#input\_cf\_geo\_restriction\_locations) | Country codes for geo restriction (e.g. `["US", "CA"]`). | `list(string)` | `[]` | no |
| <a name="input_cf_geo_restriction_type"></a> [cf\_geo\_restriction\_type](#input\_cf\_geo\_restriction\_type) | Geographic restriction type (`none`, `whitelist`, `blacklist`). | `string` | `"none"` | no |
| <a name="input_cf_ssl_acm_certificate_arn"></a> [cf\_ssl\_acm\_certificate\_arn](#input\_cf\_ssl\_acm\_certificate\_arn) | ACM certificate ARN in us-east-1 for HTTPS. | `string` | `""` | no |
| <a name="input_cf_ssl_minimum_protocol_version"></a> [cf\_ssl\_minimum\_protocol\_version](#input\_cf\_ssl\_minimum\_protocol\_version) | Minimum TLS protocol version for HTTPS. | `string` | `"TLSv1.2_2021"` | no |

---

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cf_arn"></a> [cf\_arn](#output\_cf\_arn) | ARN of the CloudFront distribution. |
| <a name="output_cf_caller_reference"></a> [cf\_caller\_reference](#output\_cf\_caller\_reference) | Caller reference of the CloudFront distribution. |
| <a name="output_cf_domain_name"></a> [cf\_domain\_name](#output\_cf\_domain\_name) | Domain name corresponding to the CloudFront distribution. |
| <a name="output_cf_etag"></a> [cf\_etag](#output\_cf\_etag) | Current version of the distribution's information. |
| <a name="output_cf_func_arn"></a> [cf\_func\_arn](#output\_cf\_func\_arn) | ARN of the created CloudFront function. |
| <a name="output_cf_hosted_zone_id"></a> [cf\_hosted\_zone\_id](#output\_cf\_hosted\_zone\_id) | Route 53 zone ID that can be used to route an Alias record. |
| <a name="output_cf_id"></a> [cf\_id](#output\_cf\_id) | Identifier of the CloudFront distribution. |
| <a name="output_cf_key_group_id"></a> [cf\_key\_group\_id](#output\_cf\_key\_group\_id) | Identifier of the created CloudFront key group. |
| <a name="output_cf_last_modified_time"></a> [cf\_last\_modified\_time](#output\_cf\_last\_modified\_time) | Date and time the distribution was last modified. |
| <a name="output_cf_status"></a> [cf\_status](#output\_cf\_status) | Current status of the distribution (e.g. `Deployed`). |
| <a name="output_oai_caller_reference"></a> [oai\_caller\_reference](#output\_oai\_caller\_reference) | Internal value used by CloudFront to allow updates to OAI. |
| <a name="output_oai_cloudfront_access_identity_path"></a> [oai\_cloudfront\_access\_identity\_path](#output\_oai\_cloudfront\_access\_identity\_path) | Shortcut path to use in S3 bucket policy statements. |
| <a name="output_oai_etag"></a> [oai\_etag](#output\_oai\_etag) | Current version of the Origin Access Identity information. |
| <a name="output_oai_iam_arn"></a> [oai\_iam\_arn](#output\_oai\_iam\_arn) | Pre-formatted IAM principal for use in S3 bucket policies. |
| <a name="output_oai_id"></a> [oai\_id](#output\_oai\_id) | Identifier of the Origin Access Identity. |
| <a name="output_oai_s3_canonical_user_id"></a> [oai\_s3\_canonical\_user\_id](#output\_oai\_s3\_canonical\_user\_id) | Amazon S3 canonical user ID for the Origin Access Identity. |

---

## License

MIT License. See [LICENSE](LICENSE) for full details.
