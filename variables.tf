# ==============================================================================
# Origin Access Identity (OAI) Variables
# ==============================================================================

variable "create_oai" {
  type        = bool
  description = "Controls whether to create a CloudFront Origin Access Identity (OAI). Set to true when restricting S3 bucket access using OAI."
  default     = false
}

variable "oai_description" {
  type        = string
  description = "Description or comment associated with the Origin Access Identity."
  default     = "Origin Access Identity for CloudFront distribution"
}

# ==============================================================================
# CloudFront Function Variables
# ==============================================================================

variable "create_cf_func" {
  type        = bool
  description = "Controls whether to create a CloudFront Function."
  default     = false
}

variable "cf_func_name" {
  type        = string
  description = "Unique name for the CloudFront function. Also matches the JavaScript source filename ('{cf_func_name}.js') in the function code directory."
  default     = ""
}

variable "cf_func_file_path" {
  type        = string
  description = "Local directory path containing the CloudFront function JavaScript file."
  default     = "./js/cf"
}

variable "cf_func_runtime" {
  type        = string
  description = "Runtime environment for the CloudFront function (e.g., 'cloudfront-js-1.0', 'cloudfront-js-2.0')."
  default     = "cloudfront-js-2.0"
}

variable "cf_func_publish" {
  type        = bool
  description = "Controls whether to publish the CloudFront function immediately upon creation or update."
  default     = true
}

# ==============================================================================
# Public Key & Key Group Variables (Signed URLs / Cookies)
# ==============================================================================

variable "create_cf_public_key" {
  type        = bool
  description = "Controls whether to create a CloudFront Public Key and associated Key Group for signed URLs or signed cookies."
  default     = false
}

variable "cf_public_key_name" {
  type        = string
  description = "Unique identifier name for the CloudFront public key. Also matches the PEM file name ('{cf_public_key_name}.pem') in the public key directory."
  default     = ""
}

variable "cf_public_key_path" {
  type        = string
  description = "Local directory path containing the PEM encoded public key file."
  default     = "./keys/cf"
}

# ==============================================================================
# CloudFront Distribution Core Variables
# ==============================================================================

variable "create_cf" {
  type        = bool
  description = "Controls whether to create the CloudFront distribution."
  default     = false
}

variable "cf_enabled" {
  type        = bool
  description = "Controls whether the CloudFront distribution is enabled to accept user requests."
  default     = true
}

variable "cf_source_domain" {
  type        = string
  description = "Identifier for the target origin (and primary domain reference). Required when creating a new distribution."
  default     = ""
}

variable "cf_source_domain_aliases" {
  type        = list(string)
  description = "List of CNAME aliases (alternate domain names) for the CloudFront distribution."
  default     = []
}

variable "cf_s3_config_enabled" {
  type        = bool
  description = "Controls whether to configure S3 origin access (OAI/OAC). Should be set to true for standard S3 REST API endpoints, and false for S3 website endpoints or custom origins."
  default     = true
}

variable "cf_custom_config_enabled" {
  type        = bool
  description = "Controls whether to use custom origin configuration. Set to true for custom HTTP/HTTPS origins or S3 website hosting endpoints."
  default     = false
}

variable "cf_endpoint" {
  type        = string
  description = "Domain name of the origin server (e.g. 'mybucket.s3.amazonaws.com' or 'example.com'). Required when creating a distribution."
  default     = ""
}

variable "cf_default_root_object" {
  type        = string
  description = "The default root object returned when an end user requests the root URL (e.g., 'index.html'). Leave empty for S3 website endpoints."
  default     = "index.html"
}

variable "cf_origin_connection_attempts" {
  type        = number
  description = "Number of times CloudFront attempts to connect to the origin before failing over or returning an error (1 to 3)."
  default     = 3
  validation {
    condition     = var.cf_origin_connection_attempts >= 1 && var.cf_origin_connection_attempts <= 3
    error_message = "cf_origin_connection_attempts must be an integer between 1 and 3."
  }
}

variable "cf_origin_connection_timeout" {
  type        = number
  description = "Number of seconds CloudFront waits when establishing a connection to the origin (1 to 10 seconds)."
  default     = 10
  validation {
    condition     = var.cf_origin_connection_timeout >= 1 && var.cf_origin_connection_timeout <= 10
    error_message = "cf_origin_connection_timeout must be an integer between 1 and 10."
  }
}

variable "cf_origin_custom_header" {
  type = list(object({
    name  = string
    value = string
  }))
  description = "List of custom HTTP header name/value pairs to send to the origin with every request."
  default     = []
}

# ==============================================================================
# Custom Origin Specific Variables
# ==============================================================================

variable "cf_custom_endpoint_http_port" {
  type        = number
  description = "HTTP port for custom origin connections."
  default     = 80
  validation {
    condition     = var.cf_custom_endpoint_http_port >= 1 && var.cf_custom_endpoint_http_port <= 65535
    error_message = "cf_custom_endpoint_http_port must be a valid port number between 1 and 65535."
  }
}

variable "cf_custom_endpoint_https_port" {
  type        = number
  description = "HTTPS port for custom origin connections."
  default     = 443
  validation {
    condition     = var.cf_custom_endpoint_https_port >= 1 && var.cf_custom_endpoint_https_port <= 65535
    error_message = "cf_custom_endpoint_https_port must be a valid port number between 1 and 65535."
  }
}

variable "cf_custom_endpoint_protocol_policy" {
  type        = string
  description = "Origin protocol policy applied to custom origin requests ('http-only', 'match-viewer', or 'https-only'). For S3 website endpoints, must be 'http-only'."
  default     = "http-only"
  validation {
    condition     = contains(["http-only", "match-viewer", "https-only"], var.cf_custom_endpoint_protocol_policy)
    error_message = "Invalid custom origin protocol policy. Valid values are: 'http-only', 'match-viewer', 'https-only'."
  }
}

variable "cf_custom_endpoint_ssl_protocols" {
  type        = list(string)
  description = "List of SSL/TLS protocols allowed when connecting to custom origins (e.g. ['TLSv1.2'])."
  default     = ["TLSv1.2"]
  validation {
    condition = alltrue([
      for protocol in var.cf_custom_endpoint_ssl_protocols :
      contains(["SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2"], protocol)
    ])
    error_message = "Invalid SSL/TLS protocol specified. Valid values are: 'SSLv3', 'TLSv1', 'TLSv1.1', 'TLSv1.2'."
  }
}

# ==============================================================================
# Distribution Behavior & Networking Variables
# ==============================================================================

variable "cf_ipv6_enabled" {
  type        = bool
  description = "Controls whether IPv6 is enabled for the CloudFront distribution."
  default     = false
}

variable "cf_custom_errors" {
  type = list(object({
    error_code    = number
    response_code = number
    response_page = string
  }))
  description = "List of custom HTTP error responses (e.g., [{ error_code = 404, response_code = 200, response_page = \"/index.html\" }])."
  default     = []
}

variable "cf_allowed_methods" {
  type        = list(string)
  description = "List of HTTP methods allowed for the default cache behavior ('GET', 'HEAD', 'POST', 'PUT', 'PATCH', 'OPTIONS', 'DELETE')."
  default     = ["GET", "HEAD", "OPTIONS"]
  validation {
    condition = alltrue([
      for method in var.cf_allowed_methods :
      contains(["GET", "HEAD", "POST", "PUT", "PATCH", "OPTIONS", "DELETE"], method)
    ])
    error_message = "Invalid HTTP method. Valid values are: 'GET', 'HEAD', 'POST', 'PUT', 'PATCH', 'OPTIONS', 'DELETE'."
  }
}

variable "cf_cached_methods" {
  type        = list(string)
  description = "List of HTTP methods for which CloudFront caches responses ('GET', 'HEAD', or 'GET', 'HEAD', 'OPTIONS')."
  default     = ["GET", "HEAD", "OPTIONS"]
  validation {
    condition = alltrue([
      for method in var.cf_cached_methods :
      contains(["GET", "HEAD", "OPTIONS"], method)
    ])
    error_message = "Invalid HTTP method for cached_methods. Valid values are a combination of: 'GET', 'HEAD', 'OPTIONS'."
  }
}

variable "cf_cache_policy_id" {
  type        = string
  description = "Unique identifier of the AWS Managed Cache Policy or custom cache policy attached to the default behavior. Defaults to CachingOptimized (4135ea2d-6df8-44a3-9df3-4b5a84be39ad)."
  default     = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
}

variable "cf_compress" {
  type        = bool
  description = "Controls whether CloudFront automatically compresses web assets for requests that include 'Accept-Encoding: gzip, deflate'."
  default     = true
}

variable "cf_protocol_policy" {
  type        = string
  description = "Protocol policy that viewers must use to access content ('allow-all', 'https-only', or 'redirect-to-https')."
  default     = "redirect-to-https"
  validation {
    condition     = contains(["allow-all", "https-only", "redirect-to-https"], var.cf_protocol_policy)
    error_message = "Invalid viewer protocol policy. Valid values are: 'allow-all', 'https-only', 'redirect-to-https'."
  }
}

variable "cf_function_associations" {
  type        = list(object({ event_type = string, function_arn = string }))
  description = "List of CloudFront Function associations (up to 2). Event types allowed: 'viewer-request' or 'viewer-response'."
  default     = []
  validation {
    condition = alltrue([
      for f in var.cf_function_associations :
      contains(["viewer-request", "viewer-response"], f.event_type)
    ])
    error_message = "Invalid event_type in cf_function_associations. Allowed values: 'viewer-request', 'viewer-response'."
  }
}

variable "cf_lambda_functions" {
  type        = list(object({ event_type = string, lambda_arn = string, include_body = bool }))
  description = "List of Lambda@Edge function associations (up to 4). Event types allowed: 'viewer-request', 'origin-request', 'viewer-response', or 'origin-response'."
  default     = []
  validation {
    condition = alltrue([
      for l in var.cf_lambda_functions :
      contains(["viewer-request", "origin-request", "viewer-response", "origin-response"], l.event_type)
    ])
    error_message = "Invalid event_type in cf_lambda_functions. Allowed values: 'viewer-request', 'origin-request', 'viewer-response', 'origin-response'."
  }
}

variable "cf_http_version" {
  type        = string
  description = "Maximum HTTP version supported by the distribution ('http1.1', 'http2', 'http2and3', or 'http3')."
  default     = "http2"
  validation {
    condition     = contains(["http1.1", "http2", "http2and3", "http3"], var.cf_http_version)
    error_message = "Invalid HTTP version. Valid values are: 'http1.1', 'http2', 'http2and3', 'http3'."
  }
}

# ==============================================================================
# Geographic Restrictions Variables
# ==============================================================================

variable "cf_geo_restriction_locations" {
  type        = list(string)
  description = "List of ISO 3166-1-alpha-2 country codes for geographic restriction (e.g. ['US', 'CA', 'GB'])."
  default     = []
}

variable "cf_geo_restriction_type" {
  type        = string
  description = "Method to restrict distribution content by geographic location ('none', 'whitelist', or 'blacklist')."
  default     = "none"
  validation {
    condition     = contains(["none", "whitelist", "blacklist"], var.cf_geo_restriction_type)
    error_message = "Invalid geographic restriction type. Valid values are: 'none', 'whitelist', 'blacklist'."
  }
}

# ==============================================================================
# SSL / TLS Certificate Variables
# ==============================================================================

variable "cf_ssl_acm_certificate_arn" {
  type        = string
  description = "ARN of the AWS Certificate Manager (ACM) SSL certificate in us-east-1 to use for custom domain HTTPS connections."
  default     = ""
}

variable "cf_ssl_minimum_protocol_version" {
  type        = string
  description = "Minimum SSL/TLS protocol version CloudFront will use for HTTPS connections."
  default     = "TLSv1.2_2021"
  validation {
    condition     = contains(["SSLv3", "TLSv1", "TLSv1_2016", "TLSv1.1_2016", "TLSv1.2_2018", "TLSv1.2_2019", "TLSv1.2_2021"], var.cf_ssl_minimum_protocol_version)
    error_message = "Invalid SSL minimum protocol version. Valid values are: 'SSLv3', 'TLSv1', 'TLSv1_2016', 'TLSv1.1_2016', 'TLSv1.2_2018', 'TLSv1.2_2019', 'TLSv1.2_2021'."
  }
}

# ==============================================================================
# TTL & Cache Control Variables
# ==============================================================================

variable "cf_default_ttl" {
  type        = number
  description = "Default amount of time (in seconds) that objects remain in CloudFront caches before forwarding another request to the origin."
  default     = 0
  validation {
    condition     = var.cf_default_ttl >= 0
    error_message = "cf_default_ttl must be greater than or equal to 0."
  }
}

variable "cf_min_ttl" {
  type        = number
  description = "Minimum amount of time (in seconds) that objects remain in CloudFront caches."
  default     = 0
  validation {
    condition     = var.cf_min_ttl >= 0
    error_message = "cf_min_ttl must be greater than or equal to 0."
  }
}

variable "cf_max_ttl" {
  type        = number
  description = "Maximum amount of time (in seconds) that objects remain in CloudFront caches."
  default     = 0
  validation {
    condition     = var.cf_max_ttl >= 0
    error_message = "cf_max_ttl must be greater than or equal to 0."
  }
}

# ==============================================================================
# Origin Access Control, Identity & Security Group References
# ==============================================================================

variable "cf_key_group_id" {
  type        = string
  description = "ID of an existing CloudFront key group used to restrict viewer access to signed URLs or signed cookies."
  default     = ""
}

variable "cf_oai" {
  type        = string
  description = "ID of an existing Origin Access Identity (OAI) (e.g., 'origin-access-identity/cloudfront/ABCDEFG1234567')."
  default     = ""
}

variable "cf_oac" {
  type        = string
  description = "ID of an existing Origin Access Control (OAC) to attach to the S3 origin."
  default     = ""
}