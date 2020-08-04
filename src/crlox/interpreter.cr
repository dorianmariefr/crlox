require "./token"
require "./environment"
require "./callable"

module Crlox
  class RuntimeError < Exception
    property :token

    @token : Token

    def initialize(token : Token, message : String)
      super(message)

      @token = token
    end
  end

  class Return < Exception
    property :value

    @value : (LiteralType | Callable)

    def initialize(value : (LiteralType | Callable))
      super()
      @value = value
    end
  end

  class Interpreter
    property :globals
    property :environment

    @globals = Environment.new
    @environment : Environment

    def initialize
      @environment = @globals
      @globals.define("clock", Callable::Clock.new)
    end

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

    def visit_logical_expression(expression)
      left = evaluate(expression.left)

      if expression.operator.type == TokenType::OR
        return left if truthy?(left)
      else
        return left if !truthy?(left)
      end

      evaluate(expression.right)
    end

    def visit_call_expression(expression)
      callee = evaluate(expression.callee)

      arguments = Array(LiteralType | Callable).new

      expression.arguments.each do |argument|
        arguments << evaluate(argument)
      end

      unless callee.is_a?(Callable)
        raise RuntimeError.new(expression.paren, "can only call functions and classes")
      end

      function = callee.as(Callable)

      if arguments.size != function.arity
        raise RuntimeError.new(
          expression.paren,
          "expected #{function.arity} arguments but got #{arguments.size}"
         )
      end

      function.call(self, arguments)
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

    def visit_while_statement(statement)
      while truthy?(evaluate(statement.condition))
        execute(statement.body)
      end

      nil
    end

    def visit_function_statement(statement)
      function = Callable::Function.new(statement)
      @environment.define(statement.name.lexeme, function)
      nil
    end

    def visit_return_statement(statement)
      value = nil
      value = evaluate(statement.value.as(Expression)) unless statement.value.nil?

      raise Return.new(value)
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
