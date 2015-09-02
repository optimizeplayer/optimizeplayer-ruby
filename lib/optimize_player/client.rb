module OptimizePlayer
  class Client
    API_URI = "http://api.optimizeplayer.com/v1/"

    def initialize(access_token, secret_key, api_endpoint=nil)
      @api_endpoint = api_endpoint || API_URI
      @access_token = access_token
      @secret_key = secret_key
    end

    def account
      @account ||= OptimizePlayer::Proxies::AccountProxy.new(self)
    end

    def projects
      @projects ||= OptimizePlayer::Proxies::ProjectProxy.new(self)
    end

    def assets
      @assets ||= OptimizePlayer::Proxies::AssetProxy.new(self)
    end

    def folders
      @folders ||= OptimizePlayer::Proxies::FolderProxy.new(self)
    end

    def integrations
      @integrations ||= OptimizePlayer::Proxies::IntegrationProxy.new(self)
    end

    def send_request(url, method, params = {})
      headers = {:accept => :json}

      url = @api_endpoint + url + "?access_token=#{@access_token}"

      case method.to_s.downcase.to_sym
      when :get, :delete
        url += "#{URI.parse(url).query ? '&' : '?'}#{uri_encode(params)}" if params && params.any?
        payload = nil
      else
        payload = params
      end

      url = OptimizePlayer::Signer.new.sign_url(url, @secret_key)

      request_opts = {
        :headers => request_headers.update(headers),
        :method => method,
        :open_timeout => 30,
        :payload => payload,
        :url => url,
        :timeout => 80
      }

      begin
        response = RestClient::Request.execute(request_opts)
      rescue RestClient::BadRequest,
             RestClient::Unauthorized,
             RestClient::ResourceNotFound,
             RestClient::Forbidden,
             RestClient::UnprocessableEntity => e

        json_obj = JSON.parse(e.http_body)
        error = json_obj['error']
        message = json_obj['message']
        error_klass_name = e.class.name.split('::')[-1]
        error_klass = Object.const_get("OptimizePlayer::Errors::#{error_klass_name}")

        raise error_klass.new(e.http_code, error, message)

      rescue RestClient::MethodNotAllowed => e
        raise OptimizePlayer::Errors::MethodNotAllowed.new(405, 'MethodNotAllowed', 'Method Not Allowed')

      rescue SocketError => e
        message = "Unexpected error communicating when trying to connect to OptimizePlayer. " +
                  "You may be seeing this message because your DNS is not working."
        raise OptimizePlayer::Errors::SocketError.new(nil, 'NetworkError', message)

      rescue Errno::ECONNREFUSED => e
        message = "Unexpected error communicating with OptimizePlayer."
        raise OptimizePlayer::Errors::ConnectionError.new(nil, 'ConnectionError', message)

      rescue RestClient::ServerBrokeConnection, RestClient::RequestTimeout => e
        message = "Could not connect to OptimizePlayer. " +
                  "Please check your internet connection and try again."
        raise OptimizePlayer::Errors::ConnectionError.new(nil, 'ConnectionError', message)

      rescue RestClient::ExceptionWithResponse => e
        if code = e.http_code and body = e.http_body
          begin
            json_obj = JSON.parse(body)
          rescue JSON::ParserError
            raise_api_error(code, body)
          end
          error = json_obj['error'] || 'error'
          message = json_obj['message'] || 'Unexpected error'

          raise OptimizePlayer::Errors::ApiError.new(code, error, message)
        else
          message = "Unexpected error communicating with OptimizePlayer."
          raise OptimizePlayer::Errors::UnhandledError.new(nil, 'UnhandledError', message)
        end
      end

      begin
        JSON.parse(response.body)
      rescue JSON::ParserError => e
        raise_api_error(response.code, response.body)
      end
    end

    private

      def request_headers
        headers = {
          :user_agent => "OptimizePlayer/v1 RubyBindings/#{OptimizePlayer::VERSION}",
          :content_type => 'application/json'
        }

        begin
          headers.update(:x_optimize_player_client_user_agent => JSON.generate(user_agent))
        rescue => e
          headers.update(:x_optimize_player_client_raw_user_agent => user_agent.inspect,
                         :error => "#{e} (#{e.class})")
        end
      end

      def raise_api_error(code, body)
        message = "Invalid response object from API: #{body.inspect}"
        raise OptimizePlayer::Errors::ApiError.new(code, 'InvalidResponse', message)
      end

      def uri_encode(params)
        flatten_params(params).map { |k,v| "#{k}=#{url_encode(v)}" }.join('&')
      end

      def url_encode(key)
        URI.escape(key.to_s, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
      end

      def flatten_params(params)
        result = []
        params.each do |key, value|
          calculated_key = url_encode(key)
          if value.is_a?(Hash)
            result += flatten_params(value, calculated_key)
          elsif value.is_a?(Array)
            result += flatten_params_array(value, calculated_key)
          else
            result << [calculated_key, value]
          end
        end
        result
      end

      def user_agent
        @uname ||= get_uname
        lang_version = "#{RUBY_VERSION} p#{RUBY_PATCHLEVEL} (#{RUBY_RELEASE_DATE})"

        {
          :bindings_version => OptimizePlayer::VERSION,
          :lang => 'ruby',
          :lang_version => lang_version,
          :platform => RUBY_PLATFORM,
          :publisher => 'optimizeplayer',
          :uname => @uname
        }

      end

      def get_uname
        `uname -a 2>/dev/null`.strip if RUBY_PLATFORM =~ /linux|darwin/i
      rescue Errno::ENOMEM => ex
        "uname lookup failed"
      end
  end
end
