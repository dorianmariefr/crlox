require "./interpreter"

module Crlox
  class Callable
    def arity
      raise "not implemented"
    end

    def call(_interpreter, _arguments)
      raise "not implemented"
    end

    def to_s
      raise "not implemented"
    end

    class Clock < Callable
      def arity
        0
      end

      def call(_interpreter, _arguments)
        Time.utc.to_unix_ms / 1000.0
      end

      def to_s
        "<native function>"
      end
    end

    class Function < Callable
      @declaration : Statement::Function
      @closure : Environment

      def initialize(declaration : Statement::Function, closure : Environment)
        @declaration = declaration
        @closure = closure
      end

      def arity
        @declaration.params.size
      end

      def call(interpreter, arguments)
        environment = Environment.new(@closure)

        (0...(@declaration.params.size)).each do |i|
          environment.define(@declaration.params[i].lexeme, arguments[i])
        end

        begin
          interpreter.execute_block(@declaration.body, environment)
        rescue return_value : Return
          return return_value.value
        end

        nil
      end

      def to_s
        "<function #{@declaration.name.lexeme}>"
      end
    end
  end
end
