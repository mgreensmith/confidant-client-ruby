require 'yaml'
require 'active_support/hash_with_indifferent_access'

module Confidant
  # Builds configuration for the Confidant client
  class Configurator
    attr_accessor :config

    # Default configraion options for this tool itself, rather than Confidant.
    # We pass these through to the CLI.
    DEFAULT_OPTS = {
      config_files: %w( ~/.confidant /etc/confidant/config ),
      profile: 'default',
      log_level: 'info'
    }.freeze

    # Default configuration options for Confidant/KMS.
    DEFAULTS = {
      token_version: 2,
      user_type: 'service',
      region: 'us-east-1'
    }.freeze

    MANDATORY_CONFIG_KEYS = {
      global: [:url, :auth_key, :from, :to],
      get_service: [:service]
    }.freeze

    def self::config
      @config || {}
    end

    def self::valid_config?(command)
      missing_global_keys = MANDATORY_CONFIG_KEYS[:global] - @config.keys
      unless missing_global_keys.empty?
        log.error "Required config options not provided: #{missing_global_keys.join(', ')}"
        return false
      end

      missing_command_keys = MANDATORY_CONFIG_KEYS[command] - @config[command].keys
      unless missing_command_keys.empty?
        log.error "Required config options for command '#{command}' not provided: #{missing_command_keys.join(', ')}"
        return false
      end

      true
    end

    def self::configure(cli_opts, command)
      config = cli_opts
      cli_opts[:config_files].each do |config_file|
        log.debug "looking for config file: #{config_file}"

        next unless File.exist?(File.expand_path(config_file))
        log.debug "found config file: #{config_file}"

        profile_config = config_from_file(File.expand_path(config_file), cli_opts[:profile])

        # Merge the CLI options config over the file profile config
        config = profile_config.merge(config)
        break
      end

      config.delete(:config_files)
      config.delete(:profile)
      config.delete(:log_level)

      # Merge config onto local DEFAULTS
      config = DEFAULTS.dup.merge(config)

      log.debug "authoritative config: #{config}"
      @config = config

      valid_config?(command)
    end

    def self::config_from_file(config_file, profile)
      content = YAML.load_file(File.expand_path(config_file))

      # Fetch options from file for the specified profile
      profile_config = content[profile].symbolize_keys!

      # Merge the :auth_context keys into the top-level hash
      profile_config.merge!(profile_config[:auth_context].symbolize_keys!)
      profile_config.delete_if { |k, _| k == :auth_context }
      log.debug "file config for profile '#{profile}': #{profile_config}"

      profile_config
    end
  end
end
