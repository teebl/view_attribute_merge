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
      collect_class_values(hash, class_values)

      hash.each_pair do |key, value|
        if special_key?(key)
          merge_special_key(key, value, output)
        elsif prefixed_key?(key)
          process_prefixed_key(key, value, output)
        else
          output[key] = value unless class_key?(key)
        end
      end
    end

    def collect_class_values(hash, class_values)
      class_value = hash[:class] || hash["class"]
      class_values.unshift(class_value) if hash.key?(:class) || hash.key?("class")
    end

    def special_key?(key)
      %i[data aria].include?(key)
    end

    def prefixed_key?(key)
      key.to_s.start_with?("data-", "aria-")
    end

    def class_key?(key)
      key.to_s == "class" || key == :class
    end

    def merge_special_key(key, value, output)
      output[key] ||= {}
      output[key].merge!(value)
    end

    def process_prefixed_key(key, value, output)
      prefix, *rest = key.to_s.split("-")
      current = (output[prefix.to_sym] ||= {})
      rest[0..-2].each { |k| current = (current[k.to_sym] ||= {}) }
      current[rest.last.to_sym] = value
    end
  end
end
