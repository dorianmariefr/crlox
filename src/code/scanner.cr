require "./token"

module Code
  class Scanner
    def initialize(source : String)
      @source = source
      @tokens = Array(Token).new
      @had_error = false
      @start = 0
      @current = 0
      @line = 1
    end

    def scan_tokens
      while !is_at_end?
        @start = @current
        scan_token
      end

      @tokens << Token.new(TokenType::EOF, "", nil, @line)
      @tokens
    end

    def scan_token
      c = advance

      if c == '('
        add_token(TokenType::LEFT_PAREN)
      elsif c == ')'
        add_token(TokenType::RIGHT_PAREN)
      elsif c == '{'
        add_token(TokenType::LEFT_BRACE)
      elsif c == '}'
        add_token(TokenType::RIGHT_BRACE)
      elsif c == ','
        add_token(TokenType::COMMA)
      elsif c == '.'
        add_token(TokenType::DOT)
      elsif c == '-'
        add_token(TokenType::MINUS)
      elsif c == '+'
        add_token(TokenType::PLUS)
      elsif c == ';'
        add_token(TokenType::SEMICOLON)
      elsif c == '*'
        add_token(TokenType::STAR)
      elsif c == '/'
        add_token(TokenType::SLASH)
      elsif c == '#'
        while peek != '\n' && !is_at_end?
          advance
        end
      elsif c == '!'
        if match('=')
          add_token(TokenType::BANG_EQUAL)
        else
          add_token(TokenType::BANG)
        end
      elsif c == '='
        if match('=')
          add_token(TokenType::EQUAL_EQUAL)
        else
          add_token(TokenType::EQUAL)
        end
      elsif c == '<'
        if match('=')
          add_token(TokenType::LESS_EQUAL)
        else
          add_token(TokenType::LESS)
        end
      elsif c == '>'
        if match('=')
          add_token(TokenType::GREATER_EQUAL)
        else
          add_token(TokenType::GREATER)
        end
      elsif c == ' ' || c == '\r' || c == '\t'
      elsif c == '\n'
        @line += 1
      else
        Code::Runner.error(@line, "unexpected character #{c}")
      end
    end

    def advance
      @current += 1
      @source[@current - 1]
    end

    def add_token(type : TokenType, literal : LiteralType = nil)
      text = @source[@start...@current]
      @tokens << Token.new(type, text, literal, @line)
    end

    def match(expected : Char)
      return false if is_at_end?
      return false if @source[@current] != expected
      @current += 1
      true
    end

    def peek
      return '\0' if is_at_end?
      @source[@current]
    end

    def is_at_end?
      @current >= @source.size
    end
  end
end
