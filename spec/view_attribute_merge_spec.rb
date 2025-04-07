# frozen_string_literal: true

RSpec.describe ViewAttributeMerge do
  it "has a version number" do
    expect(ViewAttributeMerge::VERSION).not_to be nil
  end

  context "merging hashes" do
    it "merges two hashes" do
      sample = [{ foo: "bar" }, { bar: "baz" }]
      result = { foo: "bar", bar: "baz" }

      expect(ViewAttributeMerge.mega_merge(*sample)).to eq(result)
    end

    it "merges many hashes, all passed in as arguments" do
      sample = [{ foo: "bar" }, { bar: "baz" }, { boosh: "bim" }, bam: "bop"]
      result = { foo: "bar", bar: "baz", boosh: "bim", bam: "bop" }

      expect(ViewAttributeMerge.mega_merge(*sample)).to eq(result)
    end

    it "if an array of hashes is passed in, it is flattened and incorporated" do
      sample = [[{ foo: "bar" }, { bar: "baz" }], [{ boosh: "bim" }, bam: "bop"]]
      result = { foo: "bar", bar: "baz", boosh: "bim", bam: "bop" }

      expect(ViewAttributeMerge.mega_merge(*sample)).to eq(result)
    end

    it "prioritizes values in descending order" do
      sample = [[{ foo: "right" }, { foo: "wrong" }], [{ bar: "accurate" }, bar: "incorrect"]]
      result = { foo: "right", bar: "accurate" }

      expect(ViewAttributeMerge.mega_merge(*sample)).to eq(result)
    end
  end

  context "normalized formatting" do
    it "accepts hyphenated attributes and outputs them as nested hashes"
  end

  context "turbo" do
  end

  context "stimulus" do
    it "merges data-controller attributes gracefully"
    it "merges data-actions gracefully"
  end

  context "css" do
    it "merges CSS attributes gracefully" do
    end
  end
end
