require "./token"

class Code::Scanner
  def initialize(@source : String)
    @hasError = false
  end

  def scan_tokens
    @source.split(" ")
  end

  def error(line : Integer, where : String, message : String)
    puts "[line #{line}] error #{where}: #{message}"
    @hadError = true
  end

  def hadError=(boolean : Boolean)
    @hadError = boolean
  end
end
