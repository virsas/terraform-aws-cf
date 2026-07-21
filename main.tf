resource "aws_cloudfront_origin_access_identity" "vss" {
  count = var.create_oai ? 1 : 0

  comment = var.oai_description
}

resource "aws_cloudfront_function" "vss" {
  count   = var.create_cf_func ? 1 : 0

  name    = var.cf_func_name
  runtime = var.cf_func_runtime
  publish = var.cf_func_publish

  code = file("${var.cf_func_file_path}/${var.cf_func_name}.js")
}

resource "aws_cloudfront_public_key" "vss" {
  count       = var.create_cf_public_key ? 1 : 0
  comment     = "${var.cf_public_key_name} public key"
  encoded_key = file("${var.cf_public_key_path}/${var.cf_public_key_name}.pem")
  name        = var.cf_public_key_name
}

resource "aws_cloudfront_key_group" "vss" {
  count   = var.create_cf_public_key ? 1 : 0
  comment = "Key group for ${var.cf_public_key_name}"
  items   = [aws_cloudfront_public_key.vss[0].id]
  name    = "${var.cf_public_key_name}-group"
}

resource "aws_cloudfront_distribution" "vss" {
  count = var.create_cf ? 1 : 0

  enabled                             = var.cf_enabled

  origin {
    domain_name                       = var.cf_endpoint
    origin_id                         = var.cf_source_domain

    connection_attempts               = var.cf_origin_connection_attempts
    connection_timeout                = var.cf_origin_connection_timeout

    dynamic "custom_header" {
      for_each = var.cf_origin_custom_header

      content {
        name                          = custom_header.value.name
        value                         = custom_header.value.value
      }
    }

    origin_access_control_id          = var.cf_s3_config_enabled && !var.cf_custom_config_enabled && var.cf_oac != "" ? var.cf_oac : null

    dynamic "s3_origin_config" {
      for_each = var.cf_s3_config_enabled && !var.cf_custom_config_enabled && var.cf_oai != "" && var.cf_oac == "" ? [{ oai = var.cf_oai }] : []

      content {
        origin_access_identity        = s3_origin_config.value.oai
      }
    }

    dynamic "custom_origin_config" {
      for_each = var.cf_custom_config_enabled && !var.cf_s3_config_enabled ? [{ http_port = var.cf_custom_endpoint_http_port, https_port = var.cf_custom_endpoint_https_port, protocol_policy = var.cf_custom_endpoint_protocol_policy, ssl_protocols = var.cf_custom_endpoint_ssl_protocols }] : []

      content {
        http_port                     = custom_origin_config.value.http_port
        https_port                    = custom_origin_config.value.https_port
        origin_protocol_policy        = custom_origin_config.value.protocol_policy
        origin_ssl_protocols          = custom_origin_config.value.ssl_protocols
      }
    }
  }

  aliases                             = var.cf_source_domain_aliases
  http_version                        = var.cf_http_version
  is_ipv6_enabled                     = var.cf_ipv6_enabled
  // leave empty for website endpoints or index.html for s3 rest api endpoints
  default_root_object                 = var.cf_default_root_object

  dynamic "custom_error_response" {
    for_each = var.cf_custom_errors

    content {
      error_code                      = custom_error_response.value.error_code
      response_code                   = custom_error_response.value.response_code
      response_page_path              = custom_error_response.value.response_page
    }
  }

  default_cache_behavior {
    allowed_methods                   = var.cf_allowed_methods
    cached_methods                    = var.cf_allowed_methods

    target_origin_id                  = var.cf_source_domain

    cache_policy_id                   = var.cf_cache_policy_id

    compress                          = var.cf_compress

    viewer_protocol_policy            = var.cf_protocol_policy
    default_ttl                       = var.cf_default_ttl
    min_ttl                           = var.cf_min_ttl
    max_ttl                           = var.cf_max_ttl

    trusted_key_groups                = var.cf_key_group_id != "" ? [var.cf_key_group_id] : null

    dynamic "function_association" {
      for_each = var.cf_function_associations

      content {
        event_type                    = function_association.value.event_type
        function_arn                  = function_association.value.function_arn
      }
    }

    dynamic "lambda_function_association" {
      for_each = var.cf_lambda_functions

      content {
        event_type                    = lambda_function_association.value.event_type
        lambda_arn                    = lambda_function_association.value.lambda_arn
        include_body                  = lambda_function_association.value.include_body
      }
    }
  }

  restrictions {
    geo_restriction {
      locations                       = var.cf_geo_restriction_locations
      restriction_type                = var.cf_geo_restriction_type
    }
  }

  viewer_certificate {
    acm_certificate_arn               = var.cf_ssl_acm_certificate_arn
    minimum_protocol_version          = var.cf_ssl_minimum_protocol_version
    ssl_support_method                = "sni-only"
  }

}