describe "Object#is_number? monkeypatch" do
  %w{1 2.3 4.56}.each do |s|
    it "returns true for '#{s}'" do
      expect(s.is_number?).to eq(true)
    end
  end

  %W{1x c3-po 87nskjdn3_}.each do |s|
    it "returns false for '#{s}'" do
      expect(s.is_number?).to eq(false)
    end
  end
end