# frozen_string_literal: true

module ViewAttributeMerge
  # Merges HTML view attributes from multiple sources while handling special cases:
  # - Stimulus 2.0 data attributes (controller/action/target)
  # - Nested data/aria attributes
  # - Class attribute concatenation
  # - Attribute precedence (First specified wins)
  class Merger
    @output = nil

    # Merges multiple attribute hashes into a single normalized hash
    # @param sources [Array<Hash>] attribute hashes to merge
    # @return [Hash] merged attributes with:
    #   - Stimulus attributes concatenated
    #   - Class attributes as arrays
    #   - Nested data/aria attributes merged
    #   - Later values overriding earlier ones
    def merge(*sources)
      @output = {}

      sources.each { |source| process_source(source) }

      @output
    end

    private

    def process_source(source)
      case source
      when Hash
        process_hash(source)
      when Array
        source.each { |item| process_source(item) }
      else
        raise Error, "Unprocessable_entity: #{source}"
      end
    end

    # Checks if a key matches Stimulus 2.0 attribute patterns
    # @param key [String,Symbol] attribute name to check
    # @return [Boolean] true if key matches:
    #   - data-controller
    #   - data-action
    #   - data-[controller]-target
    def stimulus_attribute?(key)
      key = key.to_s
      return false unless key.start_with?("data-")

      parts = key.split("-")
      if parts.size == 2
        %w[controller action].include?(parts[1])
      elsif parts.size == 3
        parts.last == "target"
      else
        false
      end
    end

    def process_nested_data(hash)
      hash.each do |key, value|
        if %i[controller action target].include?(key.to_sym)
          process_stimulus_value(key.to_sym, value)
        else
          @output[:data][key.to_sym] = value
        end
      end
    end

    # Processes a hash of attributes, handling special cases:
    # - Class attributes become arrays
    # - Stimulus attributes get concatenated
    # - Nested data/aria attributes get merged
    # - Other attributes get overwritten (first wins)
    # @param hash [Hash] attributes to process
    def process_hash(hash)
      hash.each_pair do |key, value|
        sym_key = key.to_sym
        case sym_key
        when :class
          process_css_value(value)
        when :data
          @output[:data] ||= {}
          process_nested_data(value)
        when :aria
          @output[:aria] ||= {}
          @output[:aria].merge!(value)
        when ->(k) { stimulus_attribute?(k) }
          process_stimulus_value(sym_key.to_s.split("-").last.to_sym, value)
        when /^data-/, /^aria-/
          process_prefixed_key(sym_key, value)
        else
          @output[sym_key] = value unless @output.key?(sym_key)
        end
      end
    end

    # Concatenates Stimulus attribute values with spaces
    # @param type [Symbol] :controller, :action or :target
    # @param value [String] new value to concatenate
    # @note Maintains existing values and joins with spaces
    def process_stimulus_value(type, value)
      @output[:data] ||= {}
      current = @output[:data][type] || ""
      @output[:data][type] = [current, value].join(" ").strip
    end

    def process_css_value(value)
      return if value.nil? || value == ""

      @output[:class] ||= []
      case value
      when String
        @output[:class].push(*value.split)
      when Array
        @output[:class].push(*value)
      else
        @output[:class].push(value.to_s)
      end
    end

    def process_prefixed_key(key, value)
      prefix, *rest = key.to_s.split("-")
      current = (@output[prefix.to_sym] ||= {})
      rest[0..-2].each { |k| current = (current[k.to_sym] ||= {}) }
      current[rest.last.to_sym] = value
    end
  end
end
