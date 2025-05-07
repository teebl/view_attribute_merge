# frozen_string_literal: true

RSpec.describe ViewAttributeMerge do
  it "has a version number" do
    expect(ViewAttributeMerge::VERSION).not_to be nil
  end

  context "merging hashes" do
    it "merges two hashes" do
      sample = [{ foo: "bar" }, { bar: "baz" }]
      result = { foo: "bar", bar: "baz" }

      expect(ViewAttributeMerge.attr_merge(*sample)).to eq(result)
    end

    it "merges many hashes, all passed in as arguments" do
      sample = [{ foo: "bar" }, { bar: "baz" }, { boosh: "bim" }, bam: "bop"]
      result = { foo: "bar", bar: "baz", boosh: "bim", bam: "bop" }

      expect(ViewAttributeMerge.attr_merge(*sample)).to eq(result)
    end

    it "if an array of hashes is passed in, it is flattened and incorporated" do
      sample = [[{ foo: "bar" }, { bar: "baz" }], [{ boosh: "bim" }, bam: "bop"]]
      result = { foo: "bar", bar: "baz", boosh: "bim", bam: "bop" }

      expect(ViewAttributeMerge.attr_merge(*sample)).to eq(result)
    end

    it "prioritizes values in descending order" do
      sample = [[{ foo: "right" }, { foo: "wrong" }], [{ bar: "accurate" }, bar: "incorrect"]]
      result = { foo: "right", bar: "accurate" }

      expect(ViewAttributeMerge.attr_merge(*sample)).to eq(result)
    end
  end

  context "data attributes" do
    it "converts hyphenated data-* attributes to nested hashes" do
      sample = [
        { "data-controller": "controller" },
        { "data-action": "action" }
      ]
      result = {
        data: { controller: "controller", action: "action" }
      }

      expect(ViewAttributeMerge.attr_merge(*sample)).to eq(result)
    end
  end

  context "aria attributes" do
    it "converts hyphenated aria-* attributes to nested hashes" do
      sample = [
        { "aria-label": "label" },
        { "aria-expanded": "true" }
      ]
      result = {
        aria: { label: "label", expanded: "true" }
      }

      expect(ViewAttributeMerge.attr_merge(*sample)).to eq(result)
    end
  end

  context "error handling" do
    it "throws an error if it receives an unprocessable element" do
      expect do
        ViewAttributeMerge.attr_merge("foo")
      end.to raise_error(ViewAttributeMerge::Error, /Unprocessable_entity: foo/)
    end
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
