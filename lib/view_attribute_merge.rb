# frozen_string_literal: true

require_relative "view_attribute_merge/version"
require_relative "view_attribute_merge/merger"

# Attribute helper for rails partials, ViewComponents, and more.
# - Concatenates when it makes sense: CSS and Stimulus.
# - Merges otherwise.
# - Source attributes are prioritized in ascending order; treats the first hash as the most important.
# - Does its best to reconcile 'data-*' and data: { *: }, output will be as a data hash.
#
# @example Merging two attribute hashes
#   ViewAttributeMerge.attr_merge({ class: "bold", data-tag="user" }, { class: "underlined", data-tag: "admin" })
#   # => {class: "bold underlined", data: { tag: "user" } }
module ViewAttributeMerge
  class Error < StandardError; end

  def self.attr_merge(*sources)
    Merger.new.merge(*sources)
  end
end
