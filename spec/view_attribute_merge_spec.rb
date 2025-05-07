# frozen_string_literal: true

RSpec.describe ViewAttributeMerge do
  it "has a version number" do
    expect(described_class::VERSION).not_to be nil
  end

  context "when merging hashes" do
    it "merges two hashes" do
      sample = [{foo: "bar"}, {bar: "baz"}]
      result = {foo: "bar", bar: "baz"}

      expect(described_class.attr_merge(*sample)).to eq(result)
    end

    it "merges many hashes, all passed in as arguments" do
      sample = [{foo: "bar"}, {bar: "baz"}, {boosh: "bim"}, bam: "bop"]
      result = {foo: "bar", bar: "baz", boosh: "bim", bam: "bop"}

      expect(described_class.attr_merge(*sample)).to eq(result)
    end

    it "if an array of hashes is passed in, it is flattened and incorporated" do
      sample = [[{foo: "bar"}, {bar: "baz"}], [{boosh: "bim"}, bam: "bop"]]
      result = {foo: "bar", bar: "baz", boosh: "bim", bam: "bop"}

      expect(described_class.attr_merge(*sample)).to eq(result)
    end

    it "prioritizes values in descending order" do
      sample = [{baz: "correct"}, [{foo: "right"}, {foo: "wrong"}], [{bar: "accurate"}, bar: "incorrect"],
        {baz: "incorrect"}]
      result = {foo: "right", bar: "accurate", baz: "correct"}

      expect(described_class.attr_merge(*sample)).to eq(result)
    end
  end

  context "with generic data attributes" do
    it "converts hyphenated data-* attributes to nested hashes" do
      sample = [
        {"data-analytics": "track"},
        {"data-tracking": "pageview"}
      ]
      result = {
        data: {analytics: "track", tracking: "pageview"}
      }

      expect(described_class.attr_merge(*sample)).to eq(result)
    end

    it "merges nested data hashes" do
      sample = [
        {data: {analytics: "track"}},
        {data: {tracking: "pageview"}}
      ]
      result = {
        data: {analytics: "track", tracking: "pageview"}
      }

      expect(described_class.attr_merge(*sample)).to eq(result)
    end
  end

  context "with aria attributes" do
    it "converts hyphenated aria-* attributes to nested hashes" do
      sample = [
        {"aria-label": "label"},
        {"aria-expanded": "true"}
      ]
      result = {
        aria: {label: "label", expanded: "true"}
      }

      expect(described_class.attr_merge(*sample)).to eq(result)
    end

    it "merges nested aria hashes" do
      sample = [
        {aria: {label: "foo"}},
        {aria: {expanded: "true"}}
      ]
      result = {
        aria: {label: "foo", expanded: "true"}
      }

      expect(described_class.attr_merge(*sample)).to eq(result)
    end
  end

  context "with css attributes" do
    it "collects class attributes and returns array" do
      sample = [
        {class: "foo"},
        {class: "bar"}
      ]
      result = {class: %w[foo bar]}

      expect(described_class.attr_merge(*sample)).to eq(result)
    end

    it "collects string and symbol class attributes" do
      sample = [
        {"class" => "foo"},
        {class: "bar"}
      ]
      result = {class: %w[foo bar]}

      expect(described_class.attr_merge(*sample)).to eq(result)
    end

    it "handles nil and empty class values" do
      sample = [
        {class: nil},
        {class: ""},
        {class: "foo"},
        {class: "bar"}
      ]
      result = {class: %w[foo bar]}

      expect(described_class.attr_merge(*sample)).to eq(result)
    end

    it "preserves order of class values" do
      sample = [
        {class: "foo bar"},
        {class: "baz"},
        {class: "foo qux"}
      ]
      result = {class: %w[foo bar baz foo qux]}

      expect(described_class.attr_merge(*sample)).to eq(result)
    end

    it "allows for duplicate classnames" do
      # having multiple identical classnames is probably a code smell, but allowable in rare cases.
      sample = [
        {class: "foo"},
        {class: "foo"}
      ]
      result = {class: %w[foo foo]}

      expect(described_class.attr_merge(*sample)).to eq(result)
    end
  end

  context "with stimulus attributes" do
    it "merges data-controller attributes into data hash" do
      sample = [
        {"data-controller": "foo"},
        {"data-controller": "bar"}
      ]
      result = {data: {controller: "foo bar"}}

      expect(described_class.attr_merge(*sample)).to eq(result)
    end

    it "merges data-action attributes into data hash" do
      sample = [
        {"data-action": "click->foo#handle"},
        {"data-action": "keyup->bar#handle"}
      ]
      result = {data: {action: "click->foo#handle keyup->bar#handle"}}

      expect(described_class.attr_merge(*sample)).to eq(result)
    end

    it "merges stimulus data-[controller]-target attributes into data hash" do
      sample = [
        {"data-foo-target": "element1"},
        {"data-bar-target": "element2"}
      ]
      result = {data: {target: "element1 element2"}}

      expect(described_class.attr_merge(*sample)).to eq(result)
    end

    it "handles existing values in stimulus attributes" do
      sample = [
        {"data-controller": "foo bar"},
        {"data-controller": "baz"}
      ]
      result = {data: {controller: "foo bar baz"}}

      expect(described_class.attr_merge(*sample)).to eq(result)
    end

    it "merges stimulus with other data attributes" do
      sample = [
        {"data-controller": "foo", "data-action": "click->foo#handle"},
        {"data-controller": "bar", "data-custom": "value"}
      ]
      result = {
        data: {
          controller: "foo bar",
          action: "click->foo#handle",
          custom: "value"
        }
      }

      expect(described_class.attr_merge(*sample)).to eq(result)
    end

    it "concatenates data-controller in both formats" do
      sample = [
        {"data-controller": "foo"},
        {data: {controller: "bar"}}
      ]
      result = {data: {controller: "foo bar"}}

      expect(described_class.attr_merge(*sample)).to eq(result)
    end

    it "concatenates data-action in both formats" do
      sample = [
        {"data-action": "click->foo#handle"},
        {data: {action: "keyup->bar#handle"}}
      ]
      result = {data: {action: "click->foo#handle keyup->bar#handle"}}

      expect(described_class.attr_merge(*sample)).to eq(result)
    end

    it "concatenates data-[controller]-target attributes" do
      sample = [
        {"data-foo-target": "element1"},
        {"data-bar-target": "element2"}
      ]
      result = {data: {target: "element1 element2"}}

      expect(described_class.attr_merge(*sample)).to eq(result)
    end

    it "handles mixed stimulus attributes" do
      sample = [
        {"data-controller": "foo", "data-foo-target": "element"},
        {"data-action": "click->foo#handle", "data-bar-target": "element2"}
      ]
      result = {
        data: {
          controller: "foo",
          action: "click->foo#handle",
          target: "element element2"
        }
      }

      expect(described_class.attr_merge(*sample)).to eq(result)
    end
  end

  context "when handling errors" do
    it "throws an error if it receives an unprocessable element" do
      expect do
        described_class.attr_merge("foo")
      end.to raise_error(ViewAttributeMerge::Error, /Unprocessable_entity: foo/)
    end
  end
end
