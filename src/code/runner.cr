require "./scanner"
require "./parser"
require "./interpreter"
require "./ast_printer"

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
      expressions = Code::Parser.new(tokens).parse
      return if @@had_error
      AstPrinter.new.print(expressions)
      @@interpreter.interpret(expressions)
    end

    def self.run_prompt
      loop do
        print "> "
        line = gets

        if line.nil?
          break
        end

        run(line)
        @@had_error = false
      end
    end
  end
end
