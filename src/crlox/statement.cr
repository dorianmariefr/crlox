require "./expression"

module Crlox
  abstract class Statement
    class Expression < Statement
      property :expression

      @expression : Crlox::Expression

      def initialize(expression : Crlox::Expression)
        @expression = expression
      end

      def accept(visitor)
        visitor.visit_expression_statement(self)
      end
    end

    class Print < Statement
      property :expression

      @expression : Crlox::Expression

      def initialize(expression : Crlox::Expression)
        @expression = expression
      end

      def accept(visitor)
        visitor.visit_print_statement(self)
      end
    end
  end
end
