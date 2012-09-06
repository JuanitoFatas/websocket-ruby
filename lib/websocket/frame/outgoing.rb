module WebSocket
  module Frame
    class Outgoing < Base

      # Is selected type supported by current draft version?
      # @return [Boolean] true if frame type is supported
      def supported?
        support_type?
      end

      # Should current frame be sent? Exclude empty frames etc.
      # @return [Boolean] true if frame should be sent
      def require_sending?
        raise NotImplementedError
      end

      # Return raw frame formatted for sending.
      def to_s
        encode_frame
      end

    end
  end
end
