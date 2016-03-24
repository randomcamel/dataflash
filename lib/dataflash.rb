require_relative "monkeypatch"

module Dataflash

  # tables are boring to type. I have computers for that.
  BYTE_SCALES = { K: 1024, M: 1024*1024, G: 1024*1024*1024 }
  BITRATES = BYTE_SCALES.inject({ b: 1, B: 8 }) do |acc, prefix|
    acc["#{prefix[0]}b".to_sym] = prefix[1] * 8
    acc["#{prefix[0]}B".to_sym] = prefix[1]
    acc
  end

  SECONDS = { s: 1, m: 60, h: 60*60 }

  class ParseError < StandardError; end

  class Parser

    attr_reader :byte_scales, :bitrates, :seconds, :units

    def initialize
      # @units = BITRATES.keys
    end

    def self.parse(answer)
      answer =~ /^([0-9.,]+)\s?([KMG]?[bB])[p\/](s|sec)$/
      num, unit, time = $1, $2, $3
      raise ParseError.new("Parse of '#{answer}' failed.") unless num && unit && time

      unit = unit.to_sym
      raise ParseError.new("Unknown unit: #{unit}") unless BITRATES[unit]

      num = num.to_f
      raise ParseError.new("What does a negative data rate mean?") if num < 0

      { num: num, unit: unit, time: time, bits: BITRATES[unit] * num }
    end
  end

  class QuestionGenerator

    UNITS = BITRATES.keys

    class <<self

      def rate_question
        # for beginner, just do "Convert 1 $thing1 to $thing2"

        from, to = UNITS.sample(2).map {|o| "#{o}ps"}
        from = "1 #{from}"
        answer_bits = Parser.parse(from)[:bits]

        print "Convert #{from} to #{to} [#{answer_bits}]: "
        response = $stdin.readline.chomp

        begin
          if Parser.parse(to)[:bits] == answer_bits
            puts "correct!\n\n"
          end
        rescue ParseError
          puts "\nInvalid answer format. Please try again.\n"
        end
      end

      def powers_question
      end
    end
  end

  class Runner
    trap("INT") { exit }

    LEVELS = { "beginner" => 1, "medium" => 2, "hard" => 3 }

    def self.run(level)
      if LEVELS.has_key?(level.to_s)
        level = LEVELS[level]
      elsif !LEVELS.has_value?(level.to_i)
        raise ArgumentError.new("Invalid level '#{level}'; levels are #{LEVELS.inspect}")
      end

      i = 0
      loop do

        QuestionGenerator.rate_question
        i += 1
        break if i > 50
      end

    end
  end
end

if __FILE__ == $0
  Dataflash::Runner.run(1)
end