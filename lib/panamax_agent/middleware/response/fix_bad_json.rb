require 'faraday_middleware/response_middleware'

module PanamaxAgent
  module Response

    # fix bad json string like returned by Journal API
    class FixBadJson < ::FaradayMiddleware::ResponseMiddleware

      define_parser do |body|
        self.fix_json_string body unless body.empty?
      end

      def parse_response?(env)
        super && !FixBadJson.valid_json?(env[:body])
      end

      def self.fix_json_string(body_str)
        if self.valid_json?(body_str)
          good_json_str = body_str
        else
          body_str.gsub!('}', '},').chop!.chop!
          good_json_str = '[' + body_str + ']'
        end
        good_json_str
      end

      def self.valid_json?(str)
        BRACKETS.include? self.first_char(str)
      end

      BRACKETS = %w- [ -
      WHITESPACE = [' ', '\n', '\r', '\t']

      # rudimentary check if the body is proper JSON formatted
      def self.first_char(body_str)
        idx = -1
        begin
          char = body_str[idx += 1]
          char = char.chr if char
        end while char && WHITESPACE.include?(char)
        char
      end

      if Faraday.respond_to? :register_middleware
        Faraday.register_middleware :response, fix_bad_json: -> { FixBadJson }
      end
    end
  end
end
