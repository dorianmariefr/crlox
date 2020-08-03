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

      def initialize(declaration : Statement::Function)
        @declaration = declaration
      end

      def arity
        @declaration.params.size
      end

      def call(interpreter, arguments)
        environment = Environment.new(interpreter.globals)

        (0...(@declaration.params.size)).each do |i|
          environment.define(@declaration.params[i].lexeme, arguments[i])
        end

        interpreter.execute_block(@declaration.body, environment)

        nil
      end

      def to_s
        "<function #{@declaration.name.lexeme}>"
      end
    end
  end
end
