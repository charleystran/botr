module BOTR

	module HTTP

        def http_backend=(backend)
            if backend.is_a?(String)
                raise ArgumentError, "Invalid HTTP backend: #{backend}" unless backend =~ /^[A-Za-z_]+$/
                file = backend.gsub(/([a-z])([A-Z])/, '\1_\2').gsub(/([A-Z])([A-Z][a-z])/, '\1_\2').downcase
                require "botr/http/#{file}"
                backend = BOTR.const_get(backend)
            end
            if backend.is_a?(Class)
                if backend.included_modules.include?(BOTR::HTTPBackend)
                    @http_backend = backend
                    @client = nil
                else
                    raise ArgumentError, "Invalid HTTP backend: #{backend.name}"
                end
            else
                if backend.class.included_modules.include?(BOTR::HTTPBackend)
                    @http_backend = backend.class
                    @client = backend
                else
                    raise ArgumentError, "Invalid HTTP backend: #{backend.class.name}"
                end
            end
        end

        def http_backend
            @http_backend ||= self.class.http_backend
        end

        def client
            @client ||= nil
            unless @client
                if !instance_of?(BOTR::Base) && http_backend == self.class.http_backend && self.class.client
                    @client = self.class.client
                else
                    @client = http_backend.new
                end
            end
            @client
        end

        def post_request(params = {})

            params = params.merge(:api_format       => api_format,
                                  :api_key          => api_key,
                                  :api_timestamp    => api_timestamp,
                                  :api_nonce        => api_nonce)
            
            client.post(api_url, params.merge(:api_signature => self.signature(params)))
        end

        def http_backend=(backend)
            if backend.is_a?(String)
                raise ArgumentError, "Invalid HTTP backend: #{backend}" unless backend =~ /^[A-Za-z_]+$/
                file = backend.gsub(/([a-z])([A-Z])/, '\1_\2').gsub(/([A-Z])([A-Z][a-z])/, '\1_\2').downcase
                require "botr/http/#{file}"
                backend = BOTR.const_get(backend)
            end
            if backend.is_a?(Class)
                if backend.included_modules.include?(BOTR::HTTPBackend)
                    @@http_backend = backend
                    @@client = nil
                else
                    raise ArgumentError, "Invalid HTTP backend: #{backend.name}"
                end
            else
                if backend.class.included_modules.include?(BOTR::HTTPBackend)
                    @@http_backend = backend.class
                    @@client = backend
                else
                    raise ArgumentError, "Invalid HTTP backend: #{backend.class.name}"
                end
            end
        end

        def http_backend
            require 'botr/http/http_backend'
            @@http_backend ||= BOTR::HTTPBackend  
        end

        def client
            @@client ||= nil
            unless @@client
                @@client = http_backend.new
            end
            @@client
        end

        def get_request(options = {})
            params = options.dup

            http      = params.delete(:client)        || client
            url       = params.delete(:api_url)       || api_url
            format    = params.delete(:api_format)    || api_format
            key 	  = params.delete(:api_key)       || api_key
            timestamp = params.delete(:api_timestamp) || api_timestamp
            nonce     = params.delete(:api_nonce)     || api_nonce
            secret    = params.delete(:secret_key)    || secret_key

            params = params.merge(:api_format    => api_format,
                                  :api_key       => api_key,
                                  :api_timestamp => api_timestamp,
                                  :api_nonce     => api_nonce)

            http.get(url, params.merge(:api_signature => self.signature(params)))
        end

        def post_request(options = {})
            params = options.dup

            http      = params.delete(:client)        || client
            url       = params.delete(:api_url)       || api_url
            format    = params.delete(:api_format)    || api_format
            key 	  = params.delete(:api_key)       || api_key
            timestamp = params.delete(:api_timestamp) || api_timestamp
            nonce     = params.delete(:api_nonce)     || api_nonce
            secret    = params.delete(:secret_key)    || secret_key

            params = params.merge(:api_format    => api_format,
                                  :api_key       => api_key,
                                  :api_timestamp => api_timestamp,
                                  :api_nonce     => api_nonce)

            http.post(url, params.merge(:api_signature => self.signature(params)))
        end

	end

end