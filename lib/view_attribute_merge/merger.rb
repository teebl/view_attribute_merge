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

    def process_hash(hash)
      hash.each_pair do |key, value|
        sym_key = key.to_sym
        case sym_key
        when :class
          process_css_value(value)
        when :'data-controller'
          process_stimulus_value(:controller, value)
        when :'data-action'
          process_stimulus_value(:action, value)
        when :'data-target'
          process_stimulus_value(:target, value)
        when :data, :aria
          @output[sym_key] ||= {}
          @output[sym_key].merge!(value)
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
