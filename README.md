# response-handler 


# response-handler for Kong apis

## Overview

The `response-handler` for Kong Gateway handle the responses coming from backend.

## Installation

1. **Clone the repository:**

   ```bash
   https://github.com/ngaikwad28/response-handler.git

=========================================================================================
### 2. Install and Enable the Plugin

1. **Install the Plugin**

   If you have LuaRocks installed, navigate to the plugin directory and run:

   ```bash
   luarocks make kong-plugin-response-handler-0.1.0.rockspec


2. **Enable the Plugin:**

   curl -i -X PATCH http://localhost:8001/services/<service_id>/plugins \
   --data "name=response-handler"









