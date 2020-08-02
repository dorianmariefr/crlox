require "./token"
require "./environment"

module Crlox
  class RuntimeError < Exception
    property :token

    @token : Token

    def initialize(token : Token, message : String)
      super(message)

      @token = token
    end
  end

  class Interpreter
    @environment = Environment.new

    def interpret(statements)
      begin
        statements.each do |statement|
          execute(statement)
        end
      rescue error : RuntimeError
        Runner.runtime_error(error)
      end
    end

    def execute(statement)
      statement.accept(self) unless statement.nil?
    end

    def visit_literal_expression(expression)
      expression.value
    end

    def visit_grouping_expression(expression)
      evaluate(expression.expression)
    end

    def visit_unary_expression(expression)
      right = evaluate(expression.right)

      if expression.operator.type == TokenType::MINUS
        -right.as(Float)
      elsif expression.operator.type == TokenType::BANG
        !truthy?(right)
      else
        raise RuntimeError.new(
          expression.operator,
          "operator must be - or !"
        )
      end
    end

    def visit_binary_expression(expression)
      left = evaluate(expression.left)
      right = evaluate(expression.right)
      type = expression.operator.type

      if type == TokenType::MINUS
        check_number_operands(expression.operator, left, right)
        left.as(Float) - right.as(Float)
      elsif type == TokenType::SLASH
        check_number_operands(expression.operator, left, right)
        left.as(Float) / right.as(Float)
      elsif type == TokenType::STAR
        check_number_operands(expression.operator, left, right)
        left.as(Float) * right.as(Float)
      elsif type == TokenType::PLUS
        if left.is_a?(Float) && right.is_a?(Float)
          left.as(Float) + right.as(Float)
        elsif left.is_a?(String) && right.is_a?(String)
          left.to_s + right.to_s
        else
          raise RuntimeError.new(
            expression.operator,
            "operands must be two numbers or two strings"
          )
        end
      elsif type == TokenType::GREATER
        check_number_operands(expression.operator, left, right)
        left.as(Float) > right.as(Float)
      elsif type == TokenType::GREATER_EQUAL
        check_number_operands(expression.operator, left, right)
        left.as(Float) >= right.as(Float)
      elsif type == TokenType::LESS
        check_number_operands(expression.operator, left, right)
        left.as(Float) < right.as(Float)
      elsif type == TokenType::LESS_EQUAL
        check_number_operands(expression.operator, left, right)
        left.as(Float) <= right.as(Float)
      elsif type == TokenType::BANG_EQUAL
        !equal?(left, right)
      elsif type == TokenType::EQUAL_EQUAL
        equal?(left, right)
      else
        raise RuntimeError.new(
          expression.operator,
          "operator not handled"
        )
      end
    end

    def visit_variable_expression(expression)
      @environment.get(expression.name)
    end

    def visit_assignment_expression(expression)
      value = evaluate(expression.value)
      @environment.assign(expression.name, value)
      value
    end

    def visit_expression_statement(statement)
      evaluate(statement.expression)
      nil
    end

    def visit_print_statement(statement)
      value = evaluate(statement.expression)
      puts(stringify(value))
      nil
    end

    def visit_var_statement(statement)
      if statement.initializer
        value = evaluate(statement.initializer.as(Expression))
      else
        value = nil
      end

      @environment.define(statement.name.lexeme, value)

      nil
    end

    def visit_block_statement(statement)
      execute_block(statement.statements, Environment.new(@environment))
    end

    def visit_if_statement(statement)
      if truthy?(evaluate(statement.condition))
        execute(statement.then_branch)
      elsif !statement.else_branch.nil?
        execute(statement.else_branch.as(Statement))
      end

      nil
    end

    def evaluate(expression : Expression)
      expression.accept(self)
    end

    def execute_block(statements, environment)
      previous = @environment

      begin
        @environment = environment

        statements.each do |statement|
          execute(statement)
        end
      ensure
        @environment = previous
      end
    end

    def truthy?(object)
      !!object # only nil and false are falsey
    end

    def equal?(a, b)
      a == b # same type and same value
    end

    def check_number_operand(operator, operand)
      return if !operand.is_a?(Float)
      raise RuntimeError.new(operator, "operand must be a number")
    end

    def check_number_operands(operator, left, right)
      return if left.is_a?(Float) && right.is_a?(Float)
      raise RuntimeError.new(operator, "operands must be numbers")
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
