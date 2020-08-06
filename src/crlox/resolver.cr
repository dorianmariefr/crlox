module Crlox
  class Resolver
    @interpreter : Interpreter
    @scopes = Array(Hash(String, Bool))

    def initialize(interpreter : Interpreter)
      @interpreter = interpreter
    end

    def visit_block_statement(statement)
      begin_scope
      resolve(statement.statements)
      end_scope
      nil
    end

    def visit_var_statement(statement)
      declare(statement.name)

      if !statement.initializer.nil?
        resolve(statement.initializer.as(Expression))
      end

      define(statement.name)

      nil
    end

    def visit_variable_expression(expression)
      if @scopes.any? && @scopes[-1][expression.name.lexeme] == false
        Runner.error(expression.name, "cannot read local variable in its own initializer")
      end

      resolve_local(expression, expression.name)

      nil
    end

    def resolve(statements : Array(Statement))
      statements.each { |statement| resolve(statement) }
    end

    def resolve(statement : Statement)
      statement.accept(self)
    end

    def resolve(expression : Expression)
      expression.accept(self)
    end

    def resolve_local(expression, name)
      i = @scopes.size - 1

      while i >= 0
        if @scopes[i].has_key?(name.lexeme)
          @interpreter.resolve(expression, @scopes.size - 1 - i)
        end

        i -= 1
      end
    end

    def declare(name : Token)
      return if @scopes.empty?

      scope = @scopes[-1]
      scope[name.lexeme] = false
    end

    def define(name : Token)
      return if @scopes.empty?

      scope[-1][name.lexeme] = true
    end

    def begin_scope
      @scopes << Hash(String, Bool).new
    end

    def end_scope
      @scopes.pop
    end
  end
end
