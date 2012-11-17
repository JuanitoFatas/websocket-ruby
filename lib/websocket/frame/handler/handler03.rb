# encoding: binary

module WebSocket
  module Frame
    module Handler
      module Handler03

        include Base

        def supported_frames
          [:text, :binary, :close, :ping, :pong]
        end

        private

        def encode_frame
          frame = ''

          opcode = type_to_opcode(@type)
          byte1 = opcode | (fin ? 0b10000000 : 0b00000000) # since more, rsv1-3 are 0 and 0x80 for Draft 4
          frame << byte1

          length = @data.size
          if length <= 125
            byte2 = length # since rsv4 is 0
            frame << byte2
          elsif length < 65536 # write 2 byte length
            frame << 126
            frame << [length].pack('n')
          else # write 8 byte length
            frame << 127
            frame << [length >> 32, length & 0xFFFFFFFF].pack("NN")
          end

          frame << @data
          frame
        rescue WebSocket::Error => e
          set_error(e.message.to_sym) and return
        end

        def decode_frame
          while @data.size > 1
            pointer = 0

            more = ((@data.getbyte(pointer) & 0b10000000) == 0b10000000) ^ fin

            raise(WebSocket::Error, :reserved_bit_used) if @data.getbyte(pointer) & 0b01110000 != 0b00000000

            opcode = @data.getbyte(pointer) & 0b00001111
            frame_type = opcode_to_type(opcode)
            pointer += 1

            raise(WebSocket::Error, :fragmented_control_frame) if more && control_frame?(frame_type)
            raise(WebSocket::Error, :data_frame_instead_continuation) if data_frame?(frame_type) && !@application_data_buffer.nil?

            mask = masking? && (@data.getbyte(pointer) & 0b10000000) == 0b10000000
            length = @data.getbyte(pointer) & 0b01111111

            raise(WebSocket::Error, :control_frame_payload_too_long) if length > 125 && control_frame?(frame_type)

            pointer += 1

            payload_length = case length
            when 127 # Length defined by 8 bytes
              # Check buffer size
              return if @data.getbyte(pointer+8-1) == nil # Buffer incomplete

              # Only using the last 4 bytes for now, till I work out how to
              # unpack 8 bytes. I'm sure 4GB frames will do for now :)
              l = @data.getbytes(pointer+4, 4).unpack('N').first
              pointer += 8
              l
            when 126 # Length defined by 2 bytes
              # Check buffer size
              return if @data.getbyte(pointer+2-1) == nil # Buffer incomplete

              l = @data.getbytes(pointer, 2).unpack('n').first
              pointer += 2
              l
            else
              length
            end

            # Compute the expected frame length
            frame_length = pointer + payload_length
            frame_length += 4 if mask

            raise(WebSocket::Error, :frame_too_long) if frame_length > MAX_FRAME_SIZE

            # Check buffer size
            return if @data.getbyte(frame_length-1) == nil # Buffer incomplete

            # Remove frame header
            @data.slice!(0...pointer)
            pointer = 0

            # Read application data (unmasked if required)
            @data.set_mask if mask
            pointer += 4 if mask
            application_data = @data.getbytes(pointer, payload_length)
            pointer += payload_length
            @data.unset_mask if mask

            # Throw away data up to pointer
            @data.slice!(0...pointer)

            raise(WebSocket::Error, :unexpected_continuation_frame) if frame_type == :continuation && !@frame_type

            if more
              @application_data_buffer ||= ''
              @application_data_buffer << application_data
              @frame_type ||= frame_type
            else
              # Message is complete
              if frame_type == :continuation
                @application_data_buffer << application_data
                message = self.class.new(:version => version, :type => @frame_type, :data => @application_data_buffer, :decoded => true)
                @application_data_buffer = nil
                @frame_type = nil
                return message
              else
                return self.class.new(:version => version, :type => frame_type, :data => application_data, :decoded => true)
              end
            end
          end
          return nil
        rescue WebSocket::Error => e
          set_error(e.message.to_sym) and return
        end

        # This allows flipping the more bit to fin for draft 04
        def fin; false; end

        def masking?; false; end

        FRAME_TYPES = {
          :continuation => 0,
          :close => 1,
          :ping => 2,
          :pong => 3,
          :text => 4,
          :binary => 5
        }

        FRAME_TYPES_INVERSE = FRAME_TYPES.invert

        def type_to_opcode(frame_type)
          FRAME_TYPES[frame_type] || raise(WebSocket::Error, :unknown_frame_type)
        end

        def opcode_to_type(opcode)
          FRAME_TYPES_INVERSE[opcode] || raise(WebSocket::Error, :unknown_opcode)
        end

      end
    end
  end
end
