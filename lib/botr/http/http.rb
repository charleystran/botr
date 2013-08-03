module BOTR

	module HTTP

		def self.included(base)
        	base.extend(ClassMethods)
        end

        def proxy=(options = {})
            @proxy = {}
            options.each do |key, value|
                if [:host, :port, :user, :pass].include?(key)
                    @proxy[key] = value
                else
                    raise ArgumentError, "Unsupported option: #{key}"
                end
            end
        end

        def proxy
            @proxy ||= self.class.proxy
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
                    @client = http_backend.new(host: proxy[:host], port: proxy[:port], username: proxy[:user], password: proxy[:pass])
                end
            end
            @client
        end

        def post_request(params = {})
            @errors ||= {}
            random = self.class.salt
            data = self.class.validate(params.merge(:errors => @errors))
            if @errors.empty?
                client.post(api_url, data.merge(:api_format		=> api_format,
                                                :api_key		=> api_key,
                                                :api_timestamp	=> api_timestamp,
                                                :api_nonce		=> api_nonce,
                                                :api_signature	=> self.class.signature(random, secret_key)))
            else
                @errors
            end
        end

        module ClassMethods

        	def proxy=(options = {})
                @@proxy = {}
                options.each do |key, value|
                    if [:host, :port, :user, :pass].include?(key)
                        @@proxy[key] = value
                    else
                        raise ArgumentError, "Unsupported option: #{key}"
                    end
                end
            end

            def proxy
                @@proxy ||= {}
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
	            require 'kayako_client/http/net_http'
	            @@http_backend ||= BOTR::HTTPBackend  
            end

            def client
                @@client ||= nil
                unless @@client
                    @@client = http_backend.new(host: proxy[:host], port: proxy[:port], username: proxy[:user], password: proxy[:pass])
                end
                @@client
            end

            def get_request(options = {})
                random = salt
                params = options.dup

                http      = params.delete(:client)        || client
                url       = params.delete(:api_url)       || api_url
                format    = params.delete(:api_format)    || api_format
                key 	  = params.delete(:api_key)       || api_key
                timestamp = params.delete(:api_timestamp) || api_timestamp
                nonce     = params.delete(:api_nonce)     || api_nonce
                secret    = params.delete(:secret_key)    || secret_key

                http.get(url, params.merge(:api_format		=> api_format,
                                           :api_key		    => api_key,
                                           :api_timestamp	=> api_timestamp,
                                           :api_nonce		=> api_nonce,
                                           :api_signature	=> self.class.signature(random, secret_key)))
            end

            def post_request(options = {})
                random = salt
                params = options.dup

                http      = params.delete(:client)        || client
                url       = params.delete(:api_url)       || api_url
                format    = params.delete(:api_format)    || api_format
                key 	  = params.delete(:api_key)       || api_key
                timestamp = params.delete(:api_timestamp) || api_timestamp
                nonce     = params.delete(:api_nonce)     || api_nonce
                secret    = params.delete(:secret_key)    || secret_key

                http.post(url, params.merge(:api_format		=> api_format,
                                            :api_key		=> api_key,
                                            :api_timestamp	=> api_timestamp,
                                            :api_nonce		=> api_nonce,
                                            :api_signature	=> self.class.signature(random, secret_key)))
            end

        end

	end

end