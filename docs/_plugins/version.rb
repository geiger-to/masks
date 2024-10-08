# frozen_string_literal: true

require_relative "../../lib/masks"

module Jekyll
  # Adds a {% version %} tag to Jekyll.
  #
  # This tag outputs the current version number of masks with "v" prepended.
  class VersionTag < Liquid::Tag
    def render(_context)
      "v#{::Masks::VERSION}"
    end
  end
end

Liquid::Template.register_tag("version", Jekyll::VersionTag)
