# frozen_string_literal: true

require_relative "view_attribute_merge/version"
require_relative "view_attribute_merge/merger"

module ViewAttributeMerge
  class Error < StandardError; end

  def self.attr_merge(*sources)
    Merger.new.merge(*sources)
  end
end
