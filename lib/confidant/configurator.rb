require 'yaml'
require 'active_support/hash_with_indifferent_access'

module Confidant
  # An invalid configuration was provided
  class ConfigurationError < StandardError
  end

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

    def self::validate_config(command = nil)
      missing_global_keys = MANDATORY_CONFIG_KEYS[:global] - @config.keys
      unless missing_global_keys.empty?
        return [false, "Required config options not provided: #{missing_global_keys.join(', ')}"]
      end

      if command && MANDATORY_CONFIG_KEYS[command]
        log.debug "Validating config for command: #{command}"
        log.debug @config
        command_config = @config[command] || {} # maybe they didn't provide any subcommand config.
        missing_command_keys = MANDATORY_CONFIG_KEYS[command] - command_config.keys
        unless missing_command_keys.empty?
          return [false, "Required config options for command '#{command}' not provided: #{missing_command_keys.join(', ')}"]
        end
      else
        # if we're not validating for a specific command
        # (i.e. this is a config for _all_ commands, not from the CLI),
        # find and validate hashes for all configured subcommands.
        MANDATORY_CONFIG_KEYS.each do |k, v|
          next unless @config[k]
          missing_command_keys = v - @config[k].keys
          unless missing_command_keys.empty?
            return [false, "Required config options for command '#{k}' not provided: #{missing_command_keys.join(', ')}"]
          end
        end
      end

      [true, nil]
    end

    def self::configure(opts, command = nil)
      # Merge 'opts' onto DEFAULT_OPTS so that we at least know how to read files.
      # This is a noop if we were called from CLI,
      # as those keys are defaults in GLI and guaranteed to exist in 'opts',
      # but this is necessary if we were invoked as a lib.
      config = DEFAULT_OPTS.dup.merge(opts)

      config[:config_files].each do |config_file|
        log.debug "looking for config file: #{config_file}"

        next unless File.exist?(File.expand_path(config_file))
        log.debug "found config file: #{config_file}"

        profile_config = config_from_file(File.expand_path(config_file), config[:profile])

        # Merge the CLI options config over the file profile config
        config = profile_config.merge(config)
        break
      end

      # We don't need any of the internal DEFAULT_OPTS any longer
      DEFAULT_OPTS.keys.each { |k| config.delete(k) }

      # Merge config onto local DEFAULTS to backfill any keys that are needed for KMS.
      config = DEFAULTS.dup.merge(config)

      log.debug "authoritative config: #{config}"
      @config = config

      valid, error_message = validate_config(command)
      raise ConfigurationError, error_message unless valid
      @config
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
