require "./token"

module Crlox
  abstract class Expression
    class Binary < Expression
      property :left
      property :operator
      property :right

      @left : Expression
      @operator : Token
      @right : Expression

      def initialize(left : Expression, operator : Token, right : Expression)
        @left = left
        @operator = operator
        @right = right
      end

      def accept(visitor)
        visitor.visit_binary_expression(self)
      end
    end

    class Grouping < Expression
      property :expression

      @expression : Expression

      def initialize(expression : Expression)
        @expression = expression
      end

      def accept(visitor)
        visitor.visit_grouping_expression(self)
      end
    end

    class Literal < Expression
      property :value

      @value : LiteralType

      def initialize(value : LiteralType)
        @value = value
      end

      def accept(visitor)
        visitor.visit_literal_expression(self)
      end
    end

    class Unary < Expression
      property :operator
      property :right

      @operator : Token
      @right : Expression

      def initialize(operator : Token, right : Expression)
        @operator = operator
        @right = right
      end

      def accept(visitor)
        visitor.visit_unary_expression(self)
      end
    end
  end
end