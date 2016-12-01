require 'configurability/config'

module Confidant
  class Configurator

    MANDATORY_OPTS = [:url, :auth_key, :from, :to]

    DEFAULTS = {
      config_files: %w( ~/.confidant /etc/confidant/config ),
      profile: 'default',
      url: nil,
      auth_key: nil,
      from: nil,
      to: nil,
      retries: 0,
      token_lifetime: 7,
      token_version: 2,
      user_type: 'service',
      mfa: false,
      assume_role: nil,
      region: 'us-east-1',
      log_level: 'info',
      get_service: {
        service: nil
      }
    }

    def self::configure(cli_opts)
      # How do we know which CLI opts were specified?
      # Check for config files
      # Once a config file is found
      # look for the cnfigured profile.
      # If found, merge it with CLI opts.
      # If not found, use CLI opts only
    end
  end
end
