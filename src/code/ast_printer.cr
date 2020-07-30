require "./expression"

module Code
  class AstPrinter
    def print(expression)
      expression.accept(self)
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

# include Code
#
# expression = Expression::Binary.new(
#   Expression::Unary.new(
#     Token.new(TokenType::MINUS, "-", nil, 1),
#     Expression::Literal.new(123)),
#   Token.new(TokenType::STAR, "*", nil, 1),
#   Expression::Grouping.new(
#     Expression::Literal.new(45.67)))
#
# puts AstPrinter.new.print(expression)
