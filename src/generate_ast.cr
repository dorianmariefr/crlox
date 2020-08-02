module Tool
  def self.define_type(writer, basename, class_name, fields)
    writer.puts "    class #{class_name} < #{basename}\n"

    fields.split(",").each do |field|
      name = field.split(":")[0].strip

      writer.puts "      property :#{name}"
    end

    writer.puts

    fields.split(",").each do |field|
      name = field.split(":")[0].strip
      type = field.split(":", 2)[1].strip

      writer.puts "      @#{name} : #{type}"
    end

    writer.puts

    writer.puts "      def initialize(#{fields})"

    fields.split(",").each do |field|
      name = field.split(":")[0].strip

      writer.puts "        @#{name} = #{name}"
    end

    writer.puts "      end"

    writer.puts
    writer.puts "      def accept(visitor)"
    writer.puts "        visitor.visit_#{class_name.underscore}_#{basename.underscore}(self)"
    writer.puts "      end"
    writer.puts "    end"
  end

  def self.define_ast(output_directory, basename, requires, types)
    File.open("#{output_directory}/#{basename.downcase}.cr", "w") do |writer|
      requires.split(",").each do |required|
        writer.puts "require \"./#{required}\""
      end

      writer.puts
      writer.puts "module Crlox"
      writer.puts "  abstract class #{basename}"

      types.each.with_index do |type, index|
        class_name = type.split("=")[0].strip
        fields = type.split("=")[1].strip

        define_type(writer, basename, class_name, fields)
        writer.puts unless index == types.size - 1
      end

      writer.puts "  end"
      writer.puts "end"
    end
  end
end

if ARGV.size != 1
  puts "USAGE: generate_ast [output directory]"
  exit(1)
end

Tool.define_ast(ARGV[0], "Expression", "token", [
  "Binary = left : Expression, operator : Token, right : Expression",
  "Grouping = expression : Expression",
  "Literal = value : LiteralType",
  "Unary = operator : Token, right : Expression",
  "Variable = name : Token",
  "Assignment = name : Token, value : Expression",
  "Logical = left : Expression, operator : Token, right : Expression"
])

Tool.define_ast(ARGV[0], "Statement", "token,expression", [
  "Expression = expression : Crlox::Expression",
  "Print = expression : Crlox::Expression",
  "Var = name : Token, initializer : (Crlox::Expression | Nil)",
  "Block = statements : Array(Statement)",
  "If = condition : Crlox::Expression, then_branch : Statement, else_branch : (Statement | Nil)"
])
