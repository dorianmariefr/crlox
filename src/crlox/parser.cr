require "./token"
require "./expression"
require "./statement"

module Crlox
  class ParseError < Exception
  end

  class Parser
    @tokens : Array(Token)
    @current = 0

    def initialize(tokens : Array(Token))
      @tokens = tokens
    end

    def parse
      statements = Array(Statement).new

      while !at_end?
        decl = declaration
        statements << decl.as(Statement) unless decl.nil?
      end

      statements
    end

    def declaration
      return var_declaration if match(TokenType::VAR)
      statement
    rescue error : ParseError
      synchronize
      nil
    end

    def statement
      return if_statement if match(TokenType::IF)
      return print_statement if match(TokenType::PRINT)
      return Statement::Block.new(block) if match(TokenType::LEFT_BRACE)

      expression_statement
    end

    def expression
      assignment
    end

    def assignment
      expression = or

      if match(TokenType::EQUAL)
        equals = previous
        value = assignment

        if expression.is_a?(Expression::Variable)
          name = expression.as(Expression::Variable).name
          return Expression::Assignment.new(name, value)
        end

        error(equals, "invalid assignment target")
      end

      expression
    end

    def or
      expression = and

      while match(TokenType::OR)
        operator = previous
        right = and
        expression = Expression::Logical.new(expression, operator, right)
      end

      expression
    end

    def and
      expression = equality

      while match(TokenType::AND)
        operator = previous
        right = equality
        expression = Expression::Logical.new(expression, operator, right)
      end

      expression
    end

    def equality
      expression = comparison

      while match(TokenType::BANG_EQUAL, TokenType::EQUAL_EQUAL)
        operator = previous
        right = comparison
        expression = Expression::Binary.new(expression, operator, right)
      end

      expression
    end

    def comparison
      expression = addition

      while match(TokenType::GREATER, TokenType::GREATER_EQUAL,
                  TokenType::LESS, TokenType::LESS_EQUAL)
        operator = previous
        right = addition
        expression = Expression::Binary.new(expression, operator, right)
      end

      expression
    end

    def addition
      expression = multiplication

      while match(TokenType::MINUS, TokenType::PLUS)
        operator = previous
        right = multiplication
        expression = Expression::Binary.new(expression, operator, right)
      end

      expression
    end

    def multiplication
      expression = unary

      while match(TokenType::SLASH, TokenType::STAR)
        operator = previous
        right = unary
        expression = Expression::Binary.new(expression, operator, right)
      end

      expression
    end

    def unary
      if match(TokenType::BANG, TokenType::MINUS)
        operator = previous
        right = unary
        Expression::Unary.new(operator, right)
      else
        primary
      end
    end

    def primary
      return Expression::Literal.new(false) if match(TokenType::FALSE)
      return Expression::Literal.new(true) if match(TokenType::TRUE)
      return Expression::Literal.new(nil) if match(TokenType::NIL)

      if match(TokenType::NUMBER, TokenType::STRING)
        Expression::Literal.new(previous.literal)
      elsif match(TokenType::IDENTIFIER)
        Expression::Variable.new(previous)
      elsif match(TokenType::LEFT_PAREN)
        grouping_expression = expression
        consume(TokenType::RIGHT_PAREN, "expected \")\" after expression")
        Expression::Grouping.new(grouping_expression)
      else
        raise error(peek, "expect expression")
      end
    end

    def print_statement
      value = expression
      consume(TokenType::SEMICOLON, "expect \";\" after value")
      Statement::Print.new(value)
    end

    def expression_statement
      expr = expression
      consume(TokenType::SEMICOLON, "expect \";\" after expression")
      Statement::Expression.new(expr)
    end

    def var_declaration
      name = consume(TokenType::IDENTIFIER, "expect variable name")

      initializer = nil
      initializer = expression if match(TokenType::EQUAL)
      consume(TokenType::SEMICOLON, "expect \";\" after variable declaration")
      Statement::Var.new(name, initializer)
    end

    def block
      statements = Array(Statement).new

      while !check(TokenType::RIGHT_BRACE) && !at_end?
        decl = declaration
        statements << decl.as(Statement) unless decl.nil?
      end

      consume(TokenType::RIGHT_BRACE, "expect \"}\" after block")
      statements
    end

    def if_statement
      consume(TokenType::LEFT_PAREN, "expect \"(\" after \"if\"")
      condition = expression
      consume(TokenType::RIGHT_PAREN, "expect \")\" after if condition")
      then_branch = statement
      else_branch = nil

      if match(TokenType::ELSE)
        else_branch = statement
      end

      Statement::If.new(condition, then_branch, else_branch)
    end

    def match(*types)
      types.each do |type|
        if check(type)
          advance
          return true
        end
      end

      false
    end

    def check(type)
      return false if at_end?
      peek.type == type
    end

    def advance
      @current += 1 unless at_end?
      previous
    end

    def at_end?
      peek.type == TokenType::EOF
    end

    def peek
      @tokens[@current]
    end

    def previous
      @tokens[@current - 1]
    end

    def consume(type : TokenType, message)
      return advance if check(type)
      raise error(peek, message)
    end

    def consume(types : Array(TokenType), message)
      types.each do |type|
        return advance if check(type)
      end

      raise error(peek, message)
    end

    def error(token, message)
      Runner.error(token, message)
      ParseError.new
    end

    def synchronize
      advance

      while !at_end?
        return if previous.type == TokenType::SEMICOLON
        return if peek.type == TokenType::CLASS
        return if peek.type == TokenType::FUN
        return if peek.type == TokenType::FOR
        return if peek.type == TokenType::IF
        return if peek.type == TokenType::WHILE
        return if peek.type == TokenType::PRINT
        return if peek.type == TokenType::RETURN

        advance
      end
    end
  end
end
