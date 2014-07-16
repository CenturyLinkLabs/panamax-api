module PanamaxAgent

  class Error < StandardError
    attr_reader :error_code
    attr_reader :cause

    def initialize(msg, error_code=nil, cause=nil)
      super(msg)
      @error_code = error_code
      @cause = cause
    end

    HTTP_CODE_MAP = {
      400 => 'BadRequest',
      401 => 'Unauthorized',
      403 => 'Forbidden',
      404 => 'NotFound',
      405 => 'MethodNotAllowed',
      406 => 'NotAcceptable',
      408 => 'RequestTimeout',
      409 => 'Conflict',
      412 => 'PreconditionFailed',
      413 => 'RequestEntityTooLarge',
      414 => 'RequestUriTooLong',
      415 => 'UnsupportedMediaType',
      416 => 'RequestRangeNotSatisfiable',
      417 => 'ExpectationFailed',
      500 => 'InternalServerError',
      501 => 'NotImplemented',
      502 => 'BadGateway',
      503 => 'ServiceUnavailable',
      504 => 'GatewayTimeout'
    }
  end

  # Define a new error class for all of the HTTP codes in the HTTP_CODE_MAP
  Error::HTTP_CODE_MAP.each do |code, class_name|
    PanamaxAgent.const_set(class_name, Class.new(Error)).const_set('HTTP_CODE', code)
  end

  class ConnectionError < Error; end
end
