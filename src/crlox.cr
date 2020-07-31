require "./crlox/runner"

if ARGV.size > 1
  puts "USAGE: crlox [file]"
  exit(1)
elsif ARGV.size == 1
  Crlox::Runner.run_file(ARGV[0])
else
  Crlox::Runner.run_prompt
end
