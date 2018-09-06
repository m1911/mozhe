require "resty.core"
local waf = require "resty.jxwaf.waf"
local config_path = "/usr/local/mozhe/nginx/conf/jxwaf/jxwaf_config.json" 
waf.init(config_path)

