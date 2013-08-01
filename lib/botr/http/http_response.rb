module BOTR

	class HTTPResponse
        attr_accessor :status, :body

        def initialize(status, body = "")
            @status = status
            @body = body
        end
    end

    class OKResponse < HTTPResponse
        def initialize(body = "")
            super(200, body)
        end
    end

    class BadRequestResponse < HTTPResponse
        def initialize(body = "")
            super(400, body)
        end
    end

    class UnauthorizedResponse < HTTPResponse
        def initialize(body = "")
            super(401, body)
        end
    end

    class ForbiddenResponse < HTTPResponse
        def initialize(body = "")
            super(403, body)
        end
    end

    class NotFoundResponse < HTTPResponse
        def initialize(body = "")
            super(404, body)
        end
    end

    class NotAllowedResponse < HTTPResponse
        def initialize(body = "")
            super(405, body)
        end
    end

end