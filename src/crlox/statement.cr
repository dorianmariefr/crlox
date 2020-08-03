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

    class If < Statement
      property :condition
      property :then_branch
      property :else_branch

      @condition : Crlox::Expression
      @then_branch : Statement
      @else_branch : (Statement | Nil)

      def initialize(condition : Crlox::Expression, then_branch : Statement, else_branch : (Statement | Nil))
        @condition = condition
        @then_branch = then_branch
        @else_branch = else_branch
      end

      def accept(visitor)
        visitor.visit_if_statement(self)
      end
    end

    class While < Statement
      property :condition
      property :body

      @condition : Crlox::Expression
      @body : Statement

      def initialize(condition : Crlox::Expression, body : Statement)
        @condition = condition
        @body = body
      end

      def accept(visitor)
        visitor.visit_while_statement(self)
      end
    end

    class Function < Statement
      property :name
      property :params
      property :body

      @name : Token
      @params : Array(Token)
      @body : Array(Statement)

      def initialize(name : Token, params : Array(Token), body : Array(Statement))
        @name = name
        @params = params
        @body = body
      end

      def accept(visitor)
        visitor.visit_function_statement(self)
      end
    end

    class Return < Statement
      property :keyword
      property :value

      @keyword : Token
      @value : Crlox::Expression

      def initialize(keyword : Token, value : Crlox::Expression)
        @keyword = keyword
        @value = value
      end

      def accept(visitor)
        visitor.visit_return_statement(self)
      end
    end
  end
end
