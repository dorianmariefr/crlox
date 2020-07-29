require "./scanner"

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

    def self.run_file(filepath)
      run(File.read(filepath))
      exit(1) if @@had_error
    end

    def self.run(source)
      scanner = Code::Scanner.new(source)
      tokens = scanner.scan_tokens

      tokens.each do |token|
        puts token.to_s
      end
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
