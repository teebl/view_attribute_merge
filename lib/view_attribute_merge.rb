# frozen_string_literal: true

require_relative "view_attribute_merge/version"

module ViewAttributeMerge
  class Error < StandardError; end

  def self.attr_merge(*options)
    output = {}

    options.reverse_each { |option_blob| process_blob(option_blob, output) }

    output
  end

  def self.process_blob(option_blob, output)
    case option_blob
    when Hash
      process_hash(option_blob, output)
    when Array
      option_blob.reverse_each { |blob| process_blob(blob, output) }
    end
  end

  def self.process_hash(hash, output)
    hash.each_pair { |key, value| output[key] = value }
  end
end
