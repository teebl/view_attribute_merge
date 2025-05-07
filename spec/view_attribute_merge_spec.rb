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
      sample = [{ baz: "correct" }, [{ foo: "right" }, { foo: "wrong" }], [{ bar: "accurate" }, bar: "incorrect"],
                { baz: "incorrect" }]
      result = { foo: "right", bar: "accurate", baz: "correct" }

      expect(ViewAttributeMerge.attr_merge(*sample)).to eq(result)
    end
  end

  context "generic data attributes" do
    it "converts hyphenated data-* attributes to nested hashes" do
      sample = [
        { "data-analytics": "track" },
        { "data-tracking": "pageview" }
      ]
      result = {
        data: { analytics: "track", tracking: "pageview" }
      }

      expect(ViewAttributeMerge.attr_merge(*sample)).to eq(result)
    end

    it "merges nested data hashes" do
      sample = [
        { data: { analytics: "track" } },
        { data: { tracking: "pageview" } }
      ]
      result = {
        data: { analytics: "track", tracking: "pageview" }
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

    it "merges nested aria hashes" do
      sample = [
        { aria: { label: "foo" } },
        { aria: { expanded: "true" } }
      ]
      result = {
        aria: { label: "foo", expanded: "true" }
      }

      expect(ViewAttributeMerge.attr_merge(*sample)).to eq(result)
    end
  end

  context "css" do
    it "collects class attributes and returns array" do
      sample = [
        { class: "foo" },
        { class: "bar" }
      ]
      result = { class: %w[foo bar] }

      expect(ViewAttributeMerge.attr_merge(*sample)).to eq(result)
    end

    it "collects string and symbol class attributes" do
      sample = [
        { "class" => "foo" },
        { class: "bar" }
      ]
      result = { class: %w[foo bar] }

      expect(ViewAttributeMerge.attr_merge(*sample)).to eq(result)
    end

    it "handles nil and empty class values" do
      sample = [
        { class: nil },
        { class: "" },
        { class: "foo" },
        { class: "bar" }
      ]
      result = { class: %w[foo bar] }

      expect(ViewAttributeMerge.attr_merge(*sample)).to eq(result)
    end

    it "preserves order of class values" do
      sample = [
        { class: "foo bar" },
        { class: "baz" },
        { class: "foo qux" }
      ]
      result = { class: %w[foo bar baz foo qux] }

      expect(ViewAttributeMerge.attr_merge(*sample)).to eq(result)
    end

    it "allows for duplicate classnames" do
      # having multiple identical classnames is probably a code smell, but allowable in rare cases.
      sample = [
        { class: "foo" },
        { class: "foo" }
      ]
      result = { class: %w[foo foo] }

      expect(ViewAttributeMerge.attr_merge(*sample)).to eq(result)
    end
  end

  context "turbo" do
  end

  context "stimulus" do
    it "merges data-controller attributes into data hash" do
      sample = [
        { "data-controller": "foo" },
        { "data-controller": "bar" }
      ]
      result = { data: { controller: "foo bar" } }

      expect(ViewAttributeMerge.attr_merge(*sample)).to eq(result)
    end

    it "merges data-action attributes into data hash" do
      sample = [
        { "data-action": "click->foo#handle" },
        { "data-action": "keyup->bar#handle" }
      ]
      result = { data: { action: "click->foo#handle keyup->bar#handle" } }

      expect(ViewAttributeMerge.attr_merge(*sample)).to eq(result)
    end

    it "merges data-target attributes into data hash" do
      sample = [
        { "data-target": "foo.element" },
        { "data-target": "bar.element" }
      ]
      result = { data: { target: "foo.element bar.element" } }

      expect(ViewAttributeMerge.attr_merge(*sample)).to eq(result)
    end

    it "handles existing values in stimulus attributes" do
      sample = [
        { "data-controller": "foo bar" },
        { "data-controller": "baz" }
      ]
      result = { data: { controller: "foo bar baz" } }

      expect(ViewAttributeMerge.attr_merge(*sample)).to eq(result)
    end

    it "merges stimulus with other data attributes" do
      sample = [
        { "data-controller": "foo", "data-action": "click->foo#handle" },
        { "data-controller": "bar", "data-custom": "value" }
      ]
      result = {
        data: {
          controller: "foo bar",
          action: "click->foo#handle",
          custom: "value"
        }
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
end
