# Version
require "optimize_player/version"

require 'cgi'
require 'set'
require 'openssl'
require 'rack/utils'
require 'rest_client'
require 'json'

require 'optimize_player/client'
require 'optimize_player/converter'
require 'optimize_player/signer'

# Proxies
require 'optimize_player/proxies/base_proxy'
require 'optimize_player/proxies/account_proxy'
require 'optimize_player/proxies/folder_proxy'
require 'optimize_player/proxies/project_proxy'
require 'optimize_player/proxies/asset_proxy'
require 'optimize_player/proxies/integration_proxy'

# Resources
require 'optimize_player/api_object'
require 'optimize_player/account'
require 'optimize_player/folder'
require 'optimize_player/project'
require 'optimize_player/asset'
require 'optimize_player/integration'
require 'optimize_player/media_info'
require 'optimize_player/encoding'

# Errors
require 'optimize_player/errors/optimize_player_error'
require 'optimize_player/errors/api_connection_error'
require 'optimize_player/errors/api_error'
require 'optimize_player/errors/bad_request'
require 'optimize_player/errors/connection_error'
require 'optimize_player/errors/forbidden'
require 'optimize_player/errors/resource_not_found'
require 'optimize_player/errors/socket_error'
require 'optimize_player/errors/unauthorized'
require 'optimize_player/errors/unhandled_error'
require 'optimize_player/errors/unprocessable_entity'
require 'optimize_player/errors/method_not_allowed'
