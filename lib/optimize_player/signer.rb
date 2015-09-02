module OptimizePlayer
  class Signer
    attr_accessor :algorithm, :default_opts

    def initialize(algorithm = "sha1", opts = {})
      default_opts = {
        :auth_scheme => "HMAC",
        :auth_param => "auth",
        :auth_header => "Authorization",
        :auth_header_format => "%{auth_scheme} %{signature}",
        :query_based => false,
        :use_alternate_date_header => false,
        :extra_auth_params => {},
        :ignore_params => []
      }
      @algorithm = algorithm
      opts[:nonce_header] ||="X-%{scheme}-Nonce" % {:scheme => (opts[:auth_scheme] || "HMAC")}
      opts[:alternate_date_header] ||= "X-%{scheme}-Date" % {:scheme => (opts[:auth_scheme] || "HMAC")}
      self.default_opts = default_opts.merge(opts)
    end

    def generate_signature(params)
      secret = params.delete(:secret)
      return if '' == secret.to_s

      OpenSSL::HMAC.hexdigest(algorithm, secret, canonical_representation(params))
    end

    def validate_url_signature(url, secret, opts = {})
      opts = default_opts.merge(opts)
      opts[:query_based] = true

      uri = parse_url(url)
      query_values = Rack::Utils.parse_nested_query(uri.query)
      return false unless query_values

      auth_params = query_values.delete(opts[:auth_param])
      return false unless auth_params

      date = auth_params["date"]
      nonce = auth_params["nonce"]
      compare_hashes(auth_params["signature"], :secret => secret, :method => "GET", :path => uri.path, :date => date, :nonce => nonce, :query => query_values, :headers => {})
    end

    def canonical_representation(params)
      rep = ""

      rep << "#{params[:method].upcase}\n"
      rep << "date:#{params[:date]}\n"
      rep << "nonce:#{params[:nonce]}\n"

      (params[:headers] || {}).sort.each do |pair|
        name,value = *pair
        rep << "#{name.downcase}:#{value}\n"
      end

      rep << params[:path]

      p = (params[:query] || {}).dup

      if !p.empty?
        query = p.sort.map do |key, value|
          "%{key}=%{value}" % {
            :key => Rack::Utils.unescape(key.to_s),
            :value => Rack::Utils.unescape(value.to_s)
          }
        end.join("&")
        rep << "?#{query}"
      end

      rep
    end

    def sign_request(url, secret, opts = {})
      opts = default_opts.merge(opts)

      uri = parse_url(url)
      headers = opts[:headers] || {}

      date = opts[:date] || Time.now.gmtime
      date = date.gmtime.strftime('%a, %d %b %Y %T GMT') if date.respond_to? :strftime

      method = opts[:method] ? opts[:method].to_s.upcase : "GET"

      query_values = Rack::Utils.parse_nested_query(uri.query)

      if query_values
        query_values.delete_if do |k,v|
          opts[:ignore_params].one? { |param| (k == param) || (k == param.to_s) }
        end
      end

      signature = generate_signature(:secret => secret, :method => method, :path => uri.path, :date => date, :nonce => opts[:nonce], :query => query_values, :headers => opts[:headers], :ignore_params => opts[:ignore_params])

      if opts[:query_based]
        auth_params = opts[:extra_auth_params].merge({
          "date" => date,
          "signature" => signature
        })
        auth_params[:nonce] = opts[:nonce] unless opts[:nonce].nil?

        query_values ||= {}
        query_values[opts[:auth_param]] = auth_params
        uri.query = Rack::Utils.build_nested_query(query_values)
      else
        headers[opts[:auth_header]]   = opts[:auth_header_format] % opts.merge({:signature => signature})
        headers[opts[:nonce_header]]  = opts[:nonce] unless opts[:nonce].nil?

        if opts[:use_alternate_date_header]
          headers[opts[:alternate_date_header]] = date
        else
          headers["Date"] = date
        end
      end

      [headers, uri.to_s]
    end

    def sign_url(url, secret, opts = {})
      opts = default_opts.merge(opts)
      opts[:query_based] = true

      headers, url = *sign_request(url, secret, opts)
      url
    end

    private

    def compare_hashes(presented, computed)
      if computed.length == presented.length then
        computed.chars.zip(presented.chars).map {|x,y| x == y}.all?
      else
        false
      end
    end

    def parse_url(url)
      return url if url.is_a?(URI)
      URI.parse(url)
    end
  end
end
