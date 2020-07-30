module Code
  alias Integer = Int32
  alias Float = Float64
  alias LiteralType = (String | Char | Float | Bool | Nil)

  enum TokenType
    LEFT_PAREN; RIGHT_PAREN; LEFT_BRACE; RIGHT_BRACE
    COMMA; DOT; MINUS; PLUS; SEMICOLON; SLASH; STAR
    BANG; BANG_EQUAL; EQUAL; EQUAL_EQUAL
    GREATER; GREATER_EQUAL; LESS; LESS_EQUAL
    IDENTIFIER; STRING; NUMBER
    AND; CLASS; ELSE; FALSE; DEFINE; FOR; IF; NIL; OR;
    PUTS; PRINT; RETURN; SUPER; SELF; TRUE; WHILE; NEWLINE
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
