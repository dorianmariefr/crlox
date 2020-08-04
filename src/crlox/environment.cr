module Crlox
  class Environment
    @enclosing : Environment?
    @values = Hash(String, (LiteralType | Callable)).new

    def initialize(enclosing : Environment? = nil)
      @enclosing = enclosing
    end

    def define(name : String, value)
      @values[name] = value
    end

    def get(name : Token)
      return @values[name.lexeme] if @values.has_key?(name.lexeme)

      return @enclosing.as(Environment).get(name) unless @enclosing.nil?

      raise RuntimeError.new(name, "undefined variable \"#{name.lexeme}\"")
    end

    def assign(name : Token, value)
      if @values.has_key?(name.lexeme)
        @values[name.lexeme] = value
        return
      end

      unless @enclosing.nil?
        @enclosing.as(Environment).assign(name, value)
        return
      end

      raise RuntimeError.new(name, "undefined variable \"#{name.lexeme}\"")
    end
  end
end
