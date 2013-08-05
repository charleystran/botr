module BOTR

	module HTTP

        def client
            @client = BOTR::HTTPBackend.new unless @client
            @client
        end

        def get_request(options = {})
            params = options.dup

            http      = params.delete(:client)        || client
            method    = params.delete(:method)
            url       = params.delete(:api_url)       || api_url(method)
            format    = params.delete(:api_format)    || api_format
            key       = params.delete(:api_key)       || api_key
            timestamp = params.delete(:api_timestamp) || api_timestamp
            nonce     = params.delete(:api_nonce)     || api_nonce
            secret    = params.delete(:api_secret_key)|| api_secret_key

            params = params.merge(:api_format    => format,
                                  :api_key       => key,
                                  :api_timestamp => timestamp,
                                  :api_nonce     => nonce)

            http.get(url, params.merge(:api_signature => self.signature(params)))
        end

        def post_request(options = {}, data_path = nil)
            params = options.dup

            http      = params.delete(:client)        || client
            method    = params.delete(:method)
            url       = params.delete(:api_url)       || api_url(method)
            format    = params.delete(:api_format)    || api_format
            key       = params.delete(:api_key)       || api_key
            timestamp = params.delete(:api_timestamp) || api_timestamp
            nonce     = params.delete(:api_nonce)     || api_nonce
            secret    = params.delete(:api_secret_key)|| api_secret_key

            params = params.merge(:api_format    => format,
                                  :api_key       => key,
                                  :api_timestamp => timestamp,
                                  :api_nonce     => nonce)

            http.post(url, params.merge(:api_signature => self.signature(params)), data_path)
        end

	end

end