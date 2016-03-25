describe Dataflash do
  describe "Parser" do

    let(:p) { Dataflash::Parser }

    let(:expected) {
      {
       "1 bps" => {:num=>1.0, :unit=>:b, :time=>"s", :bits=>1.0},
       "1 Bps" => {:num=>1.0, :unit=>:B, :time=>"s", :bits=>8.0},
       "1 Kbps" => {:num=>1.0, :unit=>:Kb, :time=>"s", :bits=>8192.0},
       "1 KBps" => {:num=>1.0, :unit=>:KB, :time=>"s", :bits=>1024.0},
       "1 Mbps" => {:num=>1.0, :unit=>:Mb, :time=>"s", :bits=>8388608.0},
       "1 MBps" => {:num=>1.0, :unit=>:MB, :time=>"s", :bits=>1048576.0},
       "1 Gbps" => {:num=>1.0, :unit=>:Gb, :time=>"s", :bits=>8589934592.0},
       "1 GBps" => {:num=>1.0, :unit=>:GB, :time=>"s", :bits=>1073741824.0},
       "2.3 bps" => {:num=>2.3, :unit=>:b, :time=>"s", :bits=>2.3},
       "2.3 Bps" => {:num=>2.3, :unit=>:B, :time=>"s", :bits=>18.4},
       "2.3 Kbps" => {:num=>2.3, :unit=>:Kb, :time=>"s", :bits=>18841.6},
       "2.3 KBps" => {:num=>2.3, :unit=>:KB, :time=>"s", :bits=>2355.2},
       "2.3 Mbps" => {:num=>2.3, :unit=>:Mb, :time=>"s", :bits=>19293798.4},
       "2.3 MBps" => {:num=>2.3, :unit=>:MB, :time=>"s", :bits=>2411724.8},
       "2.3 Gbps" => {:num=>2.3, :unit=>:Gb, :time=>"s", :bits=>19756849561.6},
       "2.3 GBps" => {:num=>2.3, :unit=>:GB, :time=>"s", :bits=>2469606195.2},
      }
    }

    it "fails to parse a negative rate" do
      expect { p.parse("-3 Mbps") }.to raise_error(Dataflash::ParseError)
    end

    it "parses a rate with comma" do
      expect(p.parse("3,000 Mbps")).to eq({:num=>3.0, :unit=>:Mb, :time=>"s", :bits=>25165824.0})
    end

    it "parses a rate with /" do
      expect(p.parse("3 Mb/s")).to eq({:num=>3.0, :unit=>:Mb, :time=>"s", :bits=>25165824.0})
    end

    [1, 2.3].each do |number|
      Dataflash::BITRATES.keys.each do |data_unit|
        answer = "#{number} #{data_unit}ps"

        it "parses '#{answer}' correctly" do
          expect(p.parse(answer)).to eq(expected[answer])
          # STDERR.puts %Q{ "#{answer}" => #{res.inspect} }
        end
      end
    end

    describe "QuestionGenerator" do
      let (:dq) { Dataflash::QuestionGenerator }
      context ".close_enough?" do
        it "has a correct default epsilon" do
          expect(dq.close_enough?(95, 100)).to eq(true)
        end

        it "uses the passed-in epsilon" do
          expect(dq.close_enough?(93, 100, 0.07)).to eq(true)
        end
      end
    end
  end
end