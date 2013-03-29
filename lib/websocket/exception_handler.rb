module WebSocket
  module ExceptionHandler

    attr_reader :error

    def self.included(base)
      base.extend(ClassMethods)
    end

    private

    # Changes state to error and sets error message
    # @param [String] message Error message to set
    def set_error(message)
      @error = message
    end

    module ClassMethods

      def rescue_method(method_name)
        define_method "#{method_name}_with_rescue" do
          begin
            send("#{method_name}_without_rescue")
          rescue WebSocket::Error => e
            set_error(e.message.to_sym) and return
          end
        end
        alias_method "#{method_name}_without_rescue", method_name
        alias_method method_name, "#{method_name}_with_rescue"
      end

    end

  end
end
