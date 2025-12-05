variable "aws_region" {
  description = "Región de AWS"
  type        = string
  default     = "us-east-1"

  validation {
    condition     = can(regex("^us-|^eu-|^ap-", var.aws_region))
    error_message = "Región AWS inválida"
  }
}

variable "environment" {
  description = "Ambiente de deployment"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Ambiente debe ser: dev, staging o prod"
  }
}

variable "project" {
  description = "Nombre del proyecto"
  type        = string
  default     = "dinex"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*$", var.project))
    error_message = "Nombre debe empezar con letra minúscula"
  }
}

variable "owner_name" {
  description = "Nombre del propietario del proyecto"
  type        = string
  default     = "DINEX"
}


variable "lambda_config" {
  description = "Configuración de la función Lambda"
  type = object({
    memory    = number
    timeout   = number
    runtime   = string
  })
  default = {
    memory    = 256
    timeout   = 10
    runtime   = "python3.11"
  }
}


variable "api_throttle_config" {
  description = "Configuración de throttling para API Gateway"
  type = object({
    rate_limit  = number
    burst_limit = number
  })
  default = {
    rate_limit  = 100
    burst_limit = 50
  }
}

variable "cloudwatch_config" {
  description = "Configuración de monitoreo y alarmas"
  type = object({
    log_retention_days = number
    alarm_threshold    = number
  })
  default = {
    log_retention_days = 7
    alarm_threshold    = 5
  }
}

variable "additional_tags" {
  description = "Tags adicionales para recursos"
  type        = map(string)
  default     = {}
}
