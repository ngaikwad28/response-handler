local typedefs = require "kong.db.schema.typedefs"

return {
  name = "response-handler",
  fields = {
    { config = {
        type = "record",
        fields = {
          { custom_setting = { type = "string", required = false } }
        }
      }
    }
  }
}
