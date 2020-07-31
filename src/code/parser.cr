require "./expression"
require "./token"

module Code
  class ParseError < Exception
  end

  class Parser
    @tokens : Array(Token)
    @current = 0

    def initialize(tokens : Array(Token))
      @tokens = tokens
    end

    def parse
      expressions = Array(Expression).new

      while !at_end?
        expressions << expression
      end

      expressions
    rescue ParseError
      Array(Expression).new
    end

    def expression
      return print if match(TokenType::PRINT)
      equality
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
      elsif match(TokenType::LEFT_PAREN)
        grouping_expression = expression
        consume(TokenType::RIGHT_PAREN, "expected \")\" after expression")
        Expression::Grouping.new(grouping_expression)
      else
        raise error(peek, "expect expression")
      end
    end

    def print
      value = expression

      consume(
        [TokenType::NEWLINE, TokenType::SEMICOLON],
        "expect newline or semicolon after value"
      )

      Expression::Print.new(value)
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
        # TODO: support multi-line expressions
        return if previous.type == TokenType::NEWLINE
        return if previous.type == TokenType::SEMICOLON
        return if peek.type == TokenType::CLASS
        return if peek.type == TokenType::DEFINE
        return if peek.type == TokenType::FOR
        return if peek.type == TokenType::IF
        return if peek.type == TokenType::WHILE
        return if peek.type == TokenType::PUTS
        return if peek.type == TokenType::PRINT
        return if peek.type == TokenType::RETURN

        advance
      end
    end
  end
end
