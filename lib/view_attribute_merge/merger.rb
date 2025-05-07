# frozen_string_literal: true

module ViewAttributeMerge
  class Merger
    @output = nil

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

    def stimulus_attribute?(key)
      key.to_s.start_with?("data-") &&
        %i[controller action target].include?(key.to_s.split("-").last.to_sym)
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
