# encoding: binary

module WebSocket
  module Frame
    module Handler
      class Handler07 < Handler05

        # Hash of frame names and it's opcodes
        FRAME_TYPES = {
          :continuation => 0,
          :text => 1,
          :binary => 2,
          :close => 8,
          :ping => 9,
          :pong => 10,
        }

        # Hash of frame opcodes and it's names
        FRAME_TYPES_INVERSE = FRAME_TYPES.invert

        def decode_frame
          result = super
          if has_close_code?(result)
            code = result.data.slice!(0..1)
            result.code = code.unpack('S').first
          end
          result
        end

        private

        def has_close_code?(frame)
          frame && frame.type == :close && !frame.data.empty?
        end

        # Convert frame type name to opcode
        # @param [Symbol] frame_type Frame type name
        # @return [Integer] opcode or nil
        # @raise [WebSocket::Error] if frame opcode is not known
        def type_to_opcode(frame_type)
          FRAME_TYPES[frame_type] || raise(WebSocket::Error::Frame::UnknownFrameType)
        end

        # Convert frame opcode to type name
        # @param [Integer] opcode Opcode
        # @return [Symbol] Frame type name or nil
        # @raise [WebSocket::Error] if frame type name is not known
        def opcode_to_type(opcode)
          FRAME_TYPES_INVERSE[opcode] || raise(WebSocket::Error::Frame::UnknownOpcode)
        end

      end
    end
  end
end
