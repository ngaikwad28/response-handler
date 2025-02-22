package = "kong-plugin-response-handler"
version = "0.1.0-1"
rockspec_format = "1.0"
source = {
  url = "git://github.com/my-repo/kong-plugin-response-handler.git",
  branch = "master",
}

dependencies = {
  "kong",
}

build = {
  type = "builtin",
  modules = {
    ["kong.plugins.response-handler"] = "src/"
  }
}

description = {
  summary = "A custom Kong plugin for response handling.",
  homepage = "https://github.com/my-repo/kong-plugin-response-handler",
  license = "MIT"
}