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
      def ask(text, &answer_proc)
        print text
        response = $stdin.readline.chomp
        yield response
      end

      def feedback(got_it_right, correct_text: "Correct!", incorrect_text: "Bzzzt!")
        if got_it_right
          puts "\n#{correct_text}\n\n"
        else
          puts "\n#{incorrect_text}\n\n"
        end
      end

      def rate_question
        # for beginner, just do "Convert 1 $thing1 to $thing2"

        from_size, to_size = UNITS.sample(2)
        from_size, to_size = %w{MB MB}    # for testing.
        from_rate, to_rate = [from_size, to_size].map { |o| "#{o}ps" }

        from_text = "1 #{from_rate}"
        answer_bits = Parser.parse(from_text)[:bits]

        ask "Convert #{from_text} to #{to_rate}: " do |response|
          begin
            # the parser only takes fully-formatted rates.
            response += " #{from_rate}" if response !~ /#{from_rate}\s*$/

            feedback(Parser.parse(response)[:bits] == answer_bits)
          rescue ParseError
            puts "\nInvalid answer format. Next!\n"
          end
        end

      end

      def powers_question
        exp = rand(16) + 4
        answer = 2**exp

        ask "What is 2**#{exp}" do |response|

        end
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