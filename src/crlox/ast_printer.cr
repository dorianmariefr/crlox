module Crlox
  class AstPrinter
    def print(statements)
      statements.each do |statement|
        puts(statement.accept(self)) unless statement.nil?
      end
    end

    def visit_binary_expression(expression)
      parenthesize(expression.operator.lexeme, [expression.left, expression.right])
    end

    def visit_grouping_expression(expression)
      parenthesize("group", expression.expression)
    end

    def visit_literal_expression(expression)
      return "nil" if expression.value == nil
      stringify(expression.value)
    end

    def visit_unary_expression(expression)
      parenthesize(expression.operator.lexeme, expression.right)
    end

    def visit_variable_expression(expression)
      expression.name.lexeme
    end

    def visit_assignment_expression(expression)
      parenthesize("assign #{expression.name.lexeme}", expression.value)
    end

    def visit_print_statement(statement)
      parenthesize("print", statement.expression)
    end

    def visit_expression_statement(statement)
      parenthesize("expression", statement.expression)
    end

    def visit_var_statement(statement)
      parenthesize("var #{statement.name.lexeme}", statement.initializer)
    end

    def visit_block_statement(statement)
      parenthesize("block", statement.statements)
    end

    def visit_if_statement(statement)
      if statement.else_branch.nil?
        parenthesize("if", [statement.condition, statement.then_branch])
      else
        parenthesize("if", [
          statement.condition,
          statement.then_branch,
          statement.else_branch.as(Statement)
        ])
      end
    end

    def parenthesize(name, expression : (Expression | Statement | Nil))
      result = "(#{name}"

      unless expression.nil?
        result += " #{expression.accept(self)}"
      end

      result + ")"
    end

    def parenthesize(name, expressions : (Array(Expression | Statement)))
      result = "(#{name}"

      expressions.each do |expression|
        unless expression.nil?
          result += " #{expression.accept(self)}"
        end
      end

      result + ")"
    end

    def stringify(object)
      if object.nil?
        "nil"
      elsif object.is_a?(Float)
        if object.to_i.to_f == object
          object.to_i.to_s
        else
          object.to_s
        end
      else
        object.to_s
      end
    end
  end
end
