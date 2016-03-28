
require "optparse"
require "ostruct"

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
        t1 = Time.now
        response = $stdin.readline.chomp
        @@elapsed_time =  sprintf("%.1f", Time.now - t1).to_f
        yield response
      end

      def feedback(got_it_right, actual_answer, correct_text: "Correct!", incorrect_text: "Bzzzt!")
        puts "    elapsed time: #{@@elapsed_time}s"

        if got_it_right
          puts "\n#{correct_text} The answer is #{actual_answer}.\n\n"
        else
          puts "\n#{incorrect_text} Correct answer is #{actual_answer}.\n\n"
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

            feedback(Parser.parse(response)[:bits] == answer_bits, "hurrrrr")
          rescue ParseError
            puts "\nInvalid answer format. Next!\n"
          end
        end

      end

      def close_enough?(input_answer, actual_answer, epsilon=0.05)
        actual_margin = ((actual_answer.to_f - input_answer) / actual_answer).abs
        @@epsilon_pct = (actual_margin * 100).to_i
        @@epsilon_pct = "< 1" if @@epsilon_pct == 0
        actual_margin <= epsilon
      end

      def powers_question(debug_exp=nil)
        exp = debug_exp || rand(20) + 4
        answer = 2**exp
        approx_ok = exp > 12

        qtext = "What is 2**#{exp}"
        if approx_ok
          ask "#{qtext} (approximate is OK)?: " do |response|
            user_answer = eval(response)
            positive = close_enough?(user_answer, answer)
            puts "    off by #{@@epsilon_pct}%"
            feedback(positive, answer, correct_text: "Close enough!")
          end
        else
          ask "#{qtext}?: " do |response|
            feedback(answer = eval(response), answer)
          end
        end
      end
    end
  end

  class Runner
    trap("INT") { puts "\nkthxbye"; exit }

    def self.run(opts)
      puts "#{opts.inspect}\n\n"

      debug_val = false
      i = 0
      loop do
        case opts.question_type
        when :rates
          QuestionGenerator.rate_question
        when :powers
          debug_val ||= 10
          QuestionGenerator.powers_question(debug_val)
        else
          raise ArgumentError.new("Unknown question type #{opts.question_type.inspect}")
        end

        i += 1
        break if i == opts.question_count
      end

    end
  end
end

if __FILE__ == $0
  option_values = OpenStruct.new(question_type: :powers,
                                 level: :beginner,
                                 debug: false, question_count: 50)

  def f(options)
    options.join("|")
  end

  OptionParser.new do |opts|
    opts.banner = "\nUsage: #{$0} [options]"

    opts.separator ""
    opts.separator "User options:"

    levels = %w{beginner medium hard}
    opts.on("-l", "--level LEVEL", levels, "Difficulty level (#{f(levels)})") do |level|
      options.level ||= levels.find_index(level)
    end

    question_types = %w{powers rates}
    opts.on("-t", "--type [TYPE]", question_types, "Type of question (#{f(question_types)})") do |type|
      option_values.question_type ||= type
    end

    opts.on("-h", "--help", "Prints this help message") do
      puts opts
      exit
    end

    opts.separator ""
    opts.separator "Development options:"

    opts.on("-n", "--num [COUNT]", Integer, "Only ask COUNT questions (defaults to 1)") do |val|
      puts val.inspect
      option_values.question_count = val || 1
    end

    opts.on("-d", "--debug", "Debug mode (same question over and over)") do |debug|
      option_values.debug ||= debug
    end

  end.parse!

  Dataflash::Runner.run(option_values)
end
