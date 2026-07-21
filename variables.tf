variable "create_oai" {
  type = bool
  description = "Whether to create a new Origin Access Identity. Defaults to false."
  default = false
}

variable "oai_description" {
  type = string
  description = "Description for the Origin Access Identity."
  default = "Origin Access Identity for CloudFront distribution"
}

variable "create_cf_func" {
  type        = bool
  description = "Whether to create a new CloudFront Function. Defaults to false."
  default     = false
}

variable "cf_func_name" {
  type        = string
  description = "The name of the CloudFront function."
  default     = ""
}

variable "cf_func_file_path" {
  type        = string
  description = "The local path to the javascript file for the function code."
  default     = "./js/cf"
}

variable "cf_func_runtime" {
  type        = string
  description = "The runtime for the CloudFront function."
  default     = "cloudfront-js-2.0"
}

variable "cf_func_publish" {
  type        = bool
  description = "Whether to publish the function immediately."
  default     = true
}

variable "create_cf_public_key" {
  type        = bool
  description = "Whether to create a new CloudFront Public Key. Defaults to false."
  default     = false
}

variable "cf_public_key_name" {
  type        = string
  description = "The name of the CloudFront public key."
  default     = ""
}

variable "cf_public_key_path" {
  type        = string
  description = "The local path to the PEM file for the public key."
  default     = "./keys/cf"
}

variable "create_cf" {
  type = bool
  description = "Whether to create a new CloudFront distribution. Defaults to false."
  default = false
}

variable "cf_enabled" {
  type = bool
  description = "Whether the CloudFront distribution is enabled."
  default = true
}

variable "cf_source_domain" {
  description = "Main CNAME record this cloudfront distribution will be serving. Required value if you are creating a new distribution."
  type        = string
  default     = ""
}

variable "cf_source_domain_aliases" {
  type = list(string)
  description = "A list of alternative domain names for the CloudFront distribution."
  default = []
}

variable "cf_s3_config_enabled" {
  type = bool
  description = "Whether to use S3 origin config. This should be true for S3 REST API endpoints and false for S3 website endpoints."
  default = true
}

variable "cf_custom_config_enabled" {
  type = bool
  description = "Whether to use custom origin config. This should be true for custom origins and false for S3 origins."
  default = false
}

variable "cf_endpoint" {
  type = string
  description = "The origin endpoint (e.g., S3 bucket endpoint) for the CloudFront distribution. Required value if you are creating a new distribution."
  default = ""
}

variable "cf_default_root_object" {
  description = "The default root object for the CloudFront distribution (e.g., 'index.html'). Leave empty for S3 website endpoints."
  type        = string
  default     = "index.html"
}

variable "cf_origin_connection_attempts" {
  type = number
  description = "The number of times CloudFront attempts to connect to the origin (1-3)."
  default = 3
  validation {
    condition     = var.cf_origin_connection_attempts >= 1 && var.cf_origin_connection_attempts <= 3
    error_message = "cf_origin_connection_attempts must be between 1 and 3."
  }
}

variable "cf_origin_connection_timeout" {
  type = number
  description = "The number of seconds CloudFront waits to connect to the origin (1-10)."
  default = 10
  validation {
    condition     = var.cf_origin_connection_timeout >= 1 && var.cf_origin_connection_timeout <= 10
    error_message = "cf_origin_connection_timeout must be between 1 and 10."
  }
}

variable "cf_origin_custom_header" {
  type = list(object({
    name = string
    value = string
  }))
  description = "A list of custom headers to add to the origin request. Eg. [{name: \"Referer\", value: \"ref-01\"}]"
  default = []
}

variable "cf_custom_endpoint_http_port" {
  type = number
  description = "The HTTP port for the custom origin."
  default = 80
}

variable "cf_custom_endpoint_https_port" {
  type = number
  description = "The HTTPS port for the custom origin."
  default = 443
}

variable "cf_custom_endpoint_protocol_policy" {
  description = "Origin protocol policy to apply to your origin. One of http-only, https-only, or match-viewer. Fow S3 website endpoint, it must be http-only. Default value."
  type        = string
  default     = "http-only"
  validation {
    condition     = contains(["http-only", "match-viewer", "https-only"], var.cf_custom_endpoint_protocol_policy)
    error_message = "Invalid protocol policy. Valid values are: 'http-only', 'match-viewer', 'https-only'"
  }
}

variable "cf_custom_endpoint_ssl_protocols" {
  type = list(string)
  description = "A list of SSL/TLS protocols for the custom origin (e.g., ['TLSv1.2'])."
  default = ["TLSv1.2"]
  validation {
    condition = alltrue([
      for protocol in var.cf_custom_endpoint_ssl_protocols : 
      contains(["SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2"], protocol)
    ])
    error_message = "Invalid SSL/TLS protocol. Valid values are: 'SSLv3', 'TLSv1', 'TLSv1.1', 'TLSv1.2'"
  }
}

variable "cf_ipv6_enabled" {
  type = bool
  description = "Whether to enable IPv6 for the CloudFront distribution."
  default = false
}

variable "cf_custom_errors" {
  type = list(object({
    error_code = number
    response_code = number
    response_page = string
  }))
  description = "A list of custom error responses for the CloudFront distribution. Eg.: [{error_code = 404, response_code = 200, response_page = \"/index.html\" }]"
  default = []
}

variable "cf_allowed_methods" {
  type = list(string)
  description = "A list of allowed HTTP methods for the CloudFront distribution. Allowed value GET | HEAD | POST | PUT | PATCH | OPTIONS | DELETE. Defaults to [\"GET\", \"HEAD\", \"OPTIONS\"]"
  default = ["GET", "HEAD", "OPTIONS"]
  validation {
    condition = alltrue([
      for method in var.cf_allowed_methods :
      contains(["GET", "HEAD", "POST", "PUT", "PATCH", "OPTIONS", "DELETE"], method)
    ])
    error_message = "Invalid HTTP method. Valid values are: 'GET', 'HEAD', 'POST', 'PUT', 'PATCH', 'OPTIONS', 'DELETE'"
  }
}

variable "cf_cache_policy_id" {
  description = "Unique identifier of the cache policy that is attached to the cache behavior. https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-managed-cache-policies.html Defaults to 4135ea2d-6df8-44a3-9df3-4b5a84be39ad."
  type        = string
  default     = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
}

variable "cf_compress" {
  type = bool
  description = "Whether to enable compression for the CloudFront distribution."
  default = true
}

variable "cf_protocol_policy" {
  type = string
  description = "The viewer protocol policy for the CloudFront distribution ('allow-all', 'https-only', or 'redirect-to-https')."
  default = "redirect-to-https"
  validation {
    condition     = contains(["allow-all", "https-only", "redirect-to-https"], var.cf_protocol_policy)
    error_message = "Invalid protocol policy. Valid values are: 'allow-all', 'https-only', 'redirect-to-https'"
  }
}

variable "cf_function_associations" {
  description = "List of up to 2 cf functions. Eg.: [{event_type = \"viewer-request\", function_arn = \"function_arn\" }]. Allowed event types: viewer-request or viewer-response"
  type        = list(object({event_type = string, function_arn = string}))
  default     = []
}

variable "cf_lambda_functions" {
  description = "List of up to 4 lambda functions. Eg.: [{event_type = \"viewer-request\", lambda_arn = \"lambda_arn\", include_body = false }]. Allowed event types: viewer-request, origin-request, viewer-response, origin-response"
  type        = list(object({event_type = string, lambda_arn = string, include_body = bool}))
  default     = []
}

variable "cf_http_version" {
  type = string
  description = "The maximum HTTP version to support ('http1.1', 'http2', 'http2and3', or 'http3')."
  default = "http2"
  validation {
    condition     = contains(["http1.1", "http2", "http2and3", "http3"], var.cf_http_version)
    error_message = "Invalid HTTP version. Valid values are: 'http1.1', 'http2', 'http2and3', 'http3'"
  }
}

variable "cf_geo_restriction_locations" {
  type = list(string)
  description = "A list of ISO 3166-1-alpha-2 country codes for geographic restriction."
  default = []
}

variable "cf_geo_restriction_type" {
  type = string
  description = "The geographic restriction type ('none', 'whitelist', or 'blacklist')."
  default = "none"
  validation {
    condition     = contains(["none", "whitelist", "blacklist"], var.cf_geo_restriction_type)
    error_message = "Invalid geographic restriction type. Valid values are: 'none', 'whitelist', 'blacklist'"
  }
}

variable "cf_ssl_acm_certificate_arn" {
  description = "ACM ARN used for SSL access. Required value. Defaults to empty string but required for HTTPS access."
  type        = string
  default     = ""
}

variable "cf_ssl_minimum_protocol_version" {
  description = "Minimum version of the SSL protocol that you want CloudFront to use for HTTPS connections. Defaults to TLSv1.2_2021"
  type        = string
  default     = "TLSv1.2_2021"
}

variable "cf_default_ttl" {
  type = number
  description = "The default TTL for cached objects (in seconds)."
  default = 0
}

variable "cf_min_ttl" {
  type = number
  description = "The minimum TTL for cached objects (in seconds)."
  default = 0
}

variable "cf_max_ttl" {
  type = number
  description = "The maximum TTL for cached objects (in seconds)."
  default = 0
}

variable "cf_key_group_id" {
  description = "The ID of the CloudFront key group to associate with the distribution. Optional value. If not provided, no key group will be associated."
  type        = string
  default     = ""
}

variable "cf_oai" {
  description = "If you want to create a distribution with Origin Access Identity you have already created. Configure this value with its ID"
  type        = string
  default     = ""
}

variable "cf_oac" {
  description = "If you want to create a distribution with Origin Access Control you have already created. Configure this value with its ID"
  type        = string
  default     = ""
}