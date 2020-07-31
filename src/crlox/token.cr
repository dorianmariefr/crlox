module Crlox
  alias Integer = Int32
  alias Float = Float64
  alias LiteralType = (String | Char | Float | Bool | Nil)

  enum TokenType
    # Single-character tokens.
    LEFT_PAREN; RIGHT_PAREN; LEFT_BRACE; RIGHT_BRACE
    COMMA; DOT; MINUS; PLUS; SEMICOLON; SLASH; STAR

    # One or two character tokens.
    BANG; BANG_EQUAL
    EQUAL; EQUAL_EQUAL
    GREATER; GREATER_EQUAL
    LESS; LESS_EQUAL

    # Literals.
    IDENTIFIER; STRING; NUMBER

    # Keywords.
    AND; CLASS; ELSE; FALSE; FUN; FOR; IF; NIL; OR
    PRINT; RETURN; SUPER; THIS; TRUE; VAR; WHILE

    EOF
  end

  class Token
    property :type, :lexeme, :literal, :line

    def initialize(type : TokenType, lexeme : String, literal : LiteralType, line : Integer)
      @type = type
      @lexeme = lexeme
      @literal = literal
      @line = line
    end

    def to_s
      "#{@type} #{@lexeme} #{@literal}"
    end
  end
end
