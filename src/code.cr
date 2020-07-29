require "./code/runner"

module Code
end

if ARGV.size > 1
  puts "USAGE: code [file]"
  exit(1)
elsif ARGV.size == 1
  Code::Runner.run_file(ARGV[0])
else
  Code::Runner.run_prompt
end
