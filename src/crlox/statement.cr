require "./token"
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

    class Var < Statement
      property :name
      property :initializer

      @name : Token
      @initializer : (Crlox::Expression | Nil)

      def initialize(name : Token, initializer : (Crlox::Expression | Nil))
        @name = name
        @initializer = initializer
      end

      def accept(visitor)
        visitor.visit_var_statement(self)
      end
    end

    class Block < Statement
      property :statements

      @statements : Array(Statement)

      def initialize(statements : Array(Statement))
        @statements = statements
      end

      def accept(visitor)
        visitor.visit_block_statement(self)
      end
    end
  end
end
