module Tool
  def self.define_type(basename, class_name, fields)
    output = "    class #{class_name} < #{basename}\n"

    fields.split(",").each do |field|
      name = field.split(":")[0].strip

      output += "      property :#{name}\n"
    end

    output += "\n"

    fields.split(",").each do |field|
      name = field.split(":")[0].strip
      type = field.split(":")[1].strip

      output += "      @#{name} : #{type}\n"
    end

    output += "\n"

    output += "      def initialize(#{fields})\n"

    fields.split(",").each do |field|
      name = field.split(":")[0].strip

      output += "        @#{name} = #{name}\n"
    end

    output += "      end\n"

    output += "\n"
    output += "      def accept(visitor)\n"
    output += "        visitor.visit_#{class_name.underscore}_#{basename.underscore}(self)\n"
    output += "      end\n"
    output += "    end\n"

    output
  end

  def self.define_ast(output_directory : String, basename : String, types : Array(String))
    filepath = "#{output_directory}/#{basename}.cr"

    output =  "module Code\n"
    output += "  abstract class #{basename}\n"

    types.each do |type|
      class_name = type.split("=")[0].strip
      fields = type.split("=")[1].strip

      output += define_type(basename, class_name, fields)
      output += "\n"
    end

    output += "  end\n"
    output += "end\n"

    File.write(filepath, output)
  end
end

if ARGV.size != 1
  puts "USAGE: generate_ast [output directory]"
  exit(1)
end

Tool.define_ast(ARGV[0], "Expression", [
  "Binary = left : Expression, operator : Token, right : Expression",
  "Grouping = expression : Expression",
  "Literal = value : LiteralType",
  "Unary = operator : Token, right : Expression",
  "Print = expression : Expression"
])
