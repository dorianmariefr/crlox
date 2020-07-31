module Crlox
  class AstPrinter
    def print(expressions)
      expressions.each do |expression|
        expression.accept(self)
      end
    end

    def visit_binary_expression(expression)
      parenthesize(expression.operator.lexeme, expression.left, expression.right)
    end

    def visit_grouping_expression(expression)
      parenthesize("group", expression.expression)
    end

    def visit_literal_expression(expression)
      return "nil" if expression.value == nil
      expression.value.to_s
    end

    def visit_unary_expression(expression)
      parenthesize(expression.operator.lexeme, expression.right)
    end

    def parenthesize(name, *expressions)
      result = "(#{name}"

      expressions.each do |expression|
        result += " #{expression.accept(self)}"
      end

      result + ")"
    end
  end
end
