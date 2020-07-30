require "./scanner"
require "./parser"
require "./ast_printer"
require "./interpreter"

module Code
  class Runner
    @@had_error = false
    @@had_runtime_error = false
    @@interpreter = Interpreter.new

    def self.report(line, where, message)
      if where.blank?
        puts "[line #{line}] error: #{message}"
      else
        puts "[line #{line}] error #{where}: #{message}"
      end

      @@had_error = true
    end

    def self.error(line : Integer, message)
      report(line, "", message)
    end

    def self.error(token : Token, message)
      if (token.type == TokenType::EOF)
        report(token.line, "at end", message)
      else
        report(token.line, "at '#{token.lexeme}'", message)
      end
    end

    def self.runtime_error(error)
      puts "#{error.message}\n[line #{error.token.line}]"
      @@had_runtime_error = true
    end

    def self.run_file(filepath)
      run(File.read(filepath))
      exit(1) if @@had_error
      exit(1) if @@had_runtime_error
    end

    def self.run(source)
      scanner = Code::Scanner.new(source)
      tokens = scanner.scan_tokens
      expression = Code::Parser.new(tokens).parse
      return if @@had_error
      return if expression.nil?
      expression = expression.as(Expression)
      puts AstPrinter.new.print(expression)
      @@interpreter.interpret(expression)
    end

    def self.run_prompt
      loop do
        print "> "
        line = gets

        if line.nil?
          break
        end

        run(line)
        @@hadError = false
      end
    end
  end
end
