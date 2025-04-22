# frozen_string_literal: true

require_relative "view_attribute_merge/version"

module ViewAttributeMerge
  include ActionView::Helpers::TagHelper
  class Error < StandardError; end

  def self.mega_merge(*hashes)
    hashes
      .flatten
      .reverse
      .reduce({}, :merge)
      .then { |merged| normalize_options(merged) }
  end

  def self.normalize_options(hash)
    hash
  end
end
