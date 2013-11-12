require 'fileutils'
require 'coffee_script/source'
require 'json'
require 'execjs'

require File.expand_path('../input/import_string', __FILE__)
require File.expand_path('../input/github_import_string', __FILE__)

module Bwoken
  class Input
    class << self

      def coffee_script? source
        source.downcase.end_with?('.coffee')
      end

      def coffee_script_source
        return @coffeescript if @coffeescript

        @coffeescript = ''
        open(CoffeeScript::Source.bundled_path) do |f|
          @coffeescript << f.read
        end
        @coffeescript
      end

      def context
        @context ||= ExecJS.compile(coffee_script_source)
      end

      def preprocess script
        script.lines.partition {|line| line =~ /^#(?:github|import) .*$/}
      end

      def process source, target
        githubs_and_imports, sans_imports = preprocess(IO.read source)

        javascript = compile_to_javascript(source, sans_imports.join)
        import_strings = githubs_to_imports(githubs_and_imports)

        write import_strings, javascript, :to => target
      end

      def compile_to_javascript source, script
        if coffee_script? source
          self.context.call 'CoffeeScript.compile', script, :bare => true
        else
          script
        end
      end

      def githubs_to_imports strings
        strings.map do |string|
          obj = import_string_object(string)
          obj.parse
          obj.to_s
        end.join("\n")
      end

      def import_string_object string
        if string =~ /^#github/
          GithubImportString.new(string)
        else
          ImportString.new(string)
        end
      end

      def write *args
        to_hash = args.last
        chunks = args[0..-2]

        File.open(to_hash[:to], 'w') do |io|
          chunks.each do |chunk|
            io.puts chunk unless chunk.nil? || chunk == ''
          end
        end
      end

    end
  end
end
