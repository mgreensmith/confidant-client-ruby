module Confidant
  module CLIHelpers
    # Given a +description+ and a +default+ value,
    # return a formatted string suitable for use in a GLI desc.
    #
    # We do this rather than setting a GLI default because those keys
    # are indistinguishable from user-provided keys when the
    # options hash is processed.
    def description_with_default(description, default)
      return "%s (default: %s)" % [description, default]
    end
  end
end
