describe Dataflash do
  describe Dataflash::Parser do
    let(:parser) { Dataflash::Parser.new }


    it "parses" do
      parser.parse("1.0 Gbps")
    end
  end
end