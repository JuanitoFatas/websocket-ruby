module WebSocket
  module Handshake
    class Server < Base

      def initialize(args = {})
        super
        @secure = !!args[:secure]
      end

      def <<(data)
        @data << data
        if parse_data
          set_version
        end
      end

      def should_respond?
        true
      end

      private

      def set_version
        @version = @headers['sec-websocket-version'].to_i if @headers['sec-websocket-version']
        @version ||= 76 if @leftovers != ""
        @version ||= 75
        include_version
      end

      def include_version
        case @version
          when 75 then extend Handler::Server75
          when 76, 0..3 then extend Handler::Server76
          when 4..13 then extend Handler::Server04
          else set_error('Unknown version') and return false
        end
        return true
      end

      PATH = /^(\w+) (\/[^\s]*) HTTP\/1\.1$/

      def parse_first_line(line)
        line_parts = line.match(PATH)
        method = line_parts[1].strip
        set_error("Must be GET request") and return unless method == "GET"

        resource_name = line_parts[2].strip
        @path, @query = resource_name.split('?', 2)

        return true
      end

    end
  end
end
