local BasePlugin = require "kong.plugins.base_plugin"
local ngx = ngx
local string = string
local json = require "cjson"

local ResponseHandler = BasePlugin:extend()

function ResponseHandler:new()
  ResponseHandler.super.new(self, "response-handler")
end

function ResponseHandler:access(conf)
  ResponseHandler.super.access(self)

  local fault_name = ngx.var.fault_name
  local resp_code = ngx.status
  local resp_content = ngx.var.response_content
  local request_path = ngx.var.request_uri
  local host = ngx.var.host
  local http_protocol = ngx.var.scheme
  local url = http_protocol .. "://" .. host .. request_path

  local responseBody, statusCode, contentType, encryptionFlag

  -- Default values
  local defaultError = '{"status":"false","responseCode":"500","message":"The system had an internal exception"}'
  
  if resp_content then
    responseBody = resp_content
    statusCode = resp_code
    contentType = 'application/json; charset=utf-8'
    encryptionFlag = true
  end
  
  if fault_name == "FailedToResolveAPIKey" or fault_name == "InvalidApiKey" then
    responseBody = '{"status":"false","responseCode":401,"message":"Unauthorized"}'
    statusCode = 401
    contentType = 'application/json; charset=utf-8'
    encryptionFlag = false
  elseif fault_name == "SpikeArrestViolation" then
    responseBody = 'Too Many Requests'
    statusCode = 429
    contentType = "text/plain"
    encryptionFlag = false
  elseif fault_name == "ExecutionFailed" then
    responseBody = 'Forbidden PNOC Security Alert: Document Structure Threat Detected'
    statusCode = 403
    contentType = "text/plain"
    encryptionFlag = false
  elseif fault_name == "ScriptExecutionFailed" then
    local cause = ngx.var.cause
    if cause == "CodeInjectionParametersScript" then
      responseBody = 'Forbidden PNOC Security Alert: Code Injection Detected'
      statusCode = 403
      contentType = "text/plain"
      encryptionFlag = false
    elseif cause == "SQLInjectionParametersScript" then
      responseBody = 'Forbidden PNOC Security Alert: SQL Attack Detected'
      statusCode = 403
      contentType = "text/plain"
      encryptionFlag = false
    end
  elseif fault_name == "InvalidJSONPath" then
    responseBody = '{"status":"false","responseCode":"8000","message":"Invalid Request"}'
    statusCode = 400
    contentType = "application/json; charset=utf-8"
    encryptionFlag = false
  elseif fault_name == "ConnectionTimeout" then
    responseBody = '{"status":"false","responseCode":"8012","message":"BACKEND_CONNECTION_TIMEOUT-Cannot connect to service"}'
    statusCode = 200
    contentType = 'application/json; charset=utf-8'
    encryptionFlag = true
  elseif fault_name == "ErrorResponseCode" then
    if resp_code == 502 then
      responseBody = '{"status":"false","responseCode":"502","message":"Bad Gateway"}'
      statusCode = 502
      contentType = 'application/json; charset=utf-8'
      encryptionFlag = true
    end
  end
  
  -- Default Error Handling
  if not statusCode then
    responseBody = defaultError
    statusCode = 500
    contentType = 'application/json; charset=utf-8'
    encryptionFlag = false
  end

  -- Setting response headers
  ngx.status = statusCode
  ngx.header["Content-Type"] = contentType
  ngx.header["Strict-Transport-Security"] = "max-age=63072000; includeSubdomains; preload"
  ngx.header["X-Content-Type-Options"] = "nosniff"
  ngx.header["X-Frame-Options"] = "DENY"
  ngx.header["X-XSS-Protection"] = "1; mode=block"
  ngx.header["Connection"] = "close"

  -- Send Response
  ngx.say(responseBody)
end

return ResponseHandler
