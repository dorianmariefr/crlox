require "./scanner"
require "./parser"
require "./ast_printer"

module Code
  class Runner
    @@had_error = false

    def self.report(line : Int32, where : String, message : String)
      if where.blank?
        puts "[line #{line}] error: #{message}"
      else
        puts "[line #{line}] error #{where}: #{message}"
      end

      @@had_error = true
    end

    def self.error(line : Int32, message : String)
      report(line, "", message)
    end

    def self.error(token : Token, message : String)
      if (token.type == TokenType::EOF)
        report(token.line, "at end", message)
      else
        report(token.line, "at '#{token.lexeme}'", message)
      end
    end

    def self.run_file(filepath)
      run(File.read(filepath))
      exit(1) if @@had_error
    end

    def self.run(source)
      scanner = Code::Scanner.new(source)
      tokens = scanner.scan_tokens
      expression = Code::Parser.new(tokens).parse
      return if @@had_error
      puts AstPrinter.new.print(expression)
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
