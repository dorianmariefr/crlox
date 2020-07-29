require "./scanner"

class Code::Runner
  def self.run(source)
    scanner = Code::Scanner.new(source)
    tokens = scanner.scan_tokens

    tokens.each do |token|
      puts token
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
      hadError = false
    end
  end
end
