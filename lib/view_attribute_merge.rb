# frozen_string_literal: true

require_relative "view_attribute_merge/version"

module ViewAttributeMerge
  class Error < StandardError; end

  def self.attr_merge(*sources)
    output = {}

    sources.reverse_each { |source| process_source(source, output) }

    output
  end

  def self.process_source(source, output)
    case source
    when Hash
      process_hash(source, output)
    when Array
      source.reverse_each { |item| process_source(item, output) }
    else
      raise Error, "Unprocessable_entity: #{source}"
    end
  end

  def self.process_hash(hash, output)
    hash.each_pair do |key, value|
      case key
      when :data, :aria
        output[key] ||= {}
        output[key].merge!(value)
      else
        if key.to_s.start_with?("data-", "aria-")
          prefix, *rest = key.to_s.split("-")
          current = (output[prefix.to_sym] ||= {})
          rest[0..-2].each { |k| current = (current[k.to_sym] ||= {}) }
          current[rest.last.to_sym] = value
        else
          output[key] = value
        end
      end
    end
  end
end
