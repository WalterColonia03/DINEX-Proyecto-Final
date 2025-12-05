
aws_region = "us-east-1"


environment = "dev"

# Configuración de Lambda 
lambda_config = {
  memory  = 256          
  timeout = 10           
  runtime = "python3.11" 
}

# Configuración de API Gateway 
api_throttle_config = {
  rate_limit  = 100 # requests por segundo
  burst_limit = 50  # picos de tráfico
}


cloudwatch_config = {
  log_retention_days = 7 
  alarm_threshold    = 5 
}

