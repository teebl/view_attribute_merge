# frozen_string_literal: true

require_relative "view_attribute_merge/version"

# TODO: write documentation
module ViewAttributeMerge
  class Error < StandardError; end

  def self.mega_merge(*hashes)
    [hashes].flatten.reverse.reduce({}, :merge)
  end
end
