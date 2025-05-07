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
    hash.each_pair { |key, value| output[key] = value }
  end
end
