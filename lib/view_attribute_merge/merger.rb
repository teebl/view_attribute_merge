# frozen_string_literal: true

module ViewAttributeMerge
  class Merger
    def merge(*sources)
      output = {}
      class_values = []

      sources.reverse_each { |source| process_source(source, output, class_values) }

      if class_values.any?
        classes = class_values.compact.map(&:to_s).map(&:strip).reject(&:empty?)
        output[:class] = classes.join(" ").split.uniq.join(" ")
      end

      output
    end

    private

    def process_source(source, output, class_values)
      case source
      when Hash
        process_hash(source, output, class_values)
      when Array
        source.reverse_each { |item| process_source(item, output, class_values) }
      else
        raise Error, "Unprocessable_entity: #{source}"
      end
    end

    def process_hash(hash, output, class_values)
      hash.each_pair do |key, value|
        sym_key = key.to_sym
        case sym_key
        when :class
          class_values.unshift(value)
        when :data, :aria
          output[sym_key] ||= {}
          output[sym_key].merge!(value)
        when /^data-/, /^aria-/
          process_prefixed_key(sym_key, value, output)
        else
          output[sym_key] = value
        end
      end
    end

    def process_prefixed_key(key, value, output)
      prefix, *rest = key.to_s.split("-")
      current = (output[prefix.to_sym] ||= {})
      rest[0..-2].each { |k| current = (current[k.to_sym] ||= {}) }
      current[rest.last.to_sym] = value
    end
  end
end
