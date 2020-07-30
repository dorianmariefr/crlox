require "./token"

module Code
  class Scanner
    @@keywords = {
      and: TokenType::AND,
      class: TokenType::CLASS,
      else: TokenType::ELSE,
      false: TokenType::FALSE,
      for: TokenType::FOR,
      define: TokenType::DEFINE,
      if: TokenType::IF,
      nil: TokenType::NIL,
      or: TokenType::OR,
      print: TokenType::PRINT,
      puts: TokenType::PUTS,
      return: TokenType::RETURN,
      super: TokenType::SUPER,
      self: TokenType::SELF,
      true: TokenType::TRUE,
      while: TokenType::WHILE,
    }

    def initialize(source : String)
      @source = source
      @tokens = Array(Token).new
      @start = 0
      @current = 0
      @line = 1
    end

    def scan_tokens
      while !at_end?
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
        while peek != '\n' && !at_end?
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
        add_token(TokenType::NEWLINE)
        @line += 1
      elsif c == '"'
        string
      elsif digit?(c)
        number
      elsif alpha?(c)
        identifier
      else
        Code::Runner.error(@line, "unexpected character #{c}")
      end
    end

    def advance
      @current += 1
      @source[@current - 1]
    end

    def add_token(type, literal = nil)
      text = @source[@start...@current]
      @tokens << Token.new(type, text, literal, @line)
    end

    def match(expected)
      return false if at_end?
      return false if @source[@current] != expected
      @current += 1
      true
    end

    def peek
      return '\0' if at_end?
      @source[@current]
    end

    def string
      while peek != '"' && !at_end?
        @line += 1 if peek == '\n'
        advance
      end

      if at_end?
        Code::Runner.error(@line, "unterminated string")
        return
      end

      advance # closing "

      value = @source[(@start + 1)...(@current - 1)]
      add_token(TokenType::STRING, value)
    end

    def digit?(c)
      c >= '0' && c <= '9'
    end

    def number
      while digit?(peek)
        advance
      end

      if peek == '.' && digit?(peek_next)
        advance # consume the .
        while digit?(peek)
          advance
        end
      end

      add_token(TokenType::NUMBER, @source[@start...@current].to_f)
    end

    def peek_next
      return '\0' if @current + 1 >= @source.size
      @source[@current + 1]
    end

    def at_end?
      @current >= @source.size
    end

    def identifier
      while alpha_numeric?(peek)
        advance
      end

      text = @source[@start...@current]
      type = @@keywords.fetch(text) { TokenType::IDENTIFIER }

      add_token(type)
    end

    def alpha?(c)
      (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == '_'
    end

    def alpha_numeric?(c)
      alpha?(c) || digit?(c)
    end
  end
end
