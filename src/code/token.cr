require "./token_type"

class Code::Token
  alias LiteralType = (Integer | String | Char | Float | Nil)

  @type : String
  @lexeme : String
  @literal : LiteralType
  @line : Integer
end
