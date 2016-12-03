require 'yaml'
require 'active_support/hash_with_indifferent_access'

module Confidant
  # Builds configuration for the Confidant client
  class Configurator
    attr_accessor :config

    # Default configraion options for the Confidant module
    # and this Configurator class, and not for the Client.
    # Pass these through to the CLI for use in the `pre` hook,
    # and strip them out of the final config hash used by the Client.
    DEFAULT_OPTS = {
      config_files: %w(~/.confidant /etc/confidant/config),
      profile: 'default',
      log_level: 'info'
    }.freeze

    # Default configuration options for the Client.
    DEFAULTS = {
      token_lifetime: 10,
      token_version: 2,
      user_type: 'service',
      region: 'us-east-1'
    }.freeze

    # Keys that must exist in the final config in order for
    # the Client to be able to function.
    MANDATORY_CONFIG_KEYS = {
      global: [:url, :auth_key, :from, :to],
      get_service: [:service]
    }.freeze

    # The loaded config hash.
    def self::config
      @config || {}
    end

    # Given a hash of configuration +opts+, and optionally the name
    # of a +command+ that may have mandatory config options,
    # load configuration from files, merge config keys together,
    # and validate the presence of sufficient top-level config keys
    # and command-specific config keys to be able to use the client.
    #
    # Stores the final merged config in Configurator.config, and
    # returns it for convenience.
    #

    def self::configure(opts, command = nil)
      # Merge 'opts' onto DEFAULT_OPTS so that we can self-configure.
      # This is a noop if we were called from CLI,
      # as those keys are defaults in GLI and guaranteed to exist in 'opts',
      # but this is necessary if we were invoked as a lib.
      config = DEFAULT_OPTS.dup.merge(opts)
      log.debug "Local config: #{config}"

      # Merge local config over the profile config from file.
      config = profile_config(
        config[:config_files],
        config[:profile]
      ).dup.merge(config)

      # We don't need any of the internal DEFAULT_OPTS any longer
      DEFAULT_OPTS.keys.each { |k| config.delete(k) }

      # Merge config onto local DEFAULTS
      # to backfill any keys that are needed for KMS.
      config = DEFAULTS.dup.merge(config)

      validate_config(config, command)
      log.debug "Authoritative config: #{config}"
      @config = config
      @config
    end

    # Validate the provided +config+ for the presence of
    # all global mandatory config keys. If +command+ is provided,
    # validate the presence of all mandatory config keys specific
    # to that command, otherwise validate that mandatory config keys
    # exist for any command keys that exist in the top-level hash.
    # Raises +ConfigurationError+ if mandatory config options are missing.
    def self::validate_config(config, command = nil)
      missing_keys = MANDATORY_CONFIG_KEYS[:global] - config.keys

      commands_to_verify = if command
                             [command.to_sym]
                           else
                             (MANDATORY_CONFIG_KEYS.keys & config.keys)
                           end

      commands_to_verify.each do |cmd|
        missing = missing_keys_for_command(cmd, config)
        next if missing.empty?
        missing_keys << "#{cmd}[#{missing.join(',')}]"
      end

      return true if missing_keys.empty?
      raise ConfigurationError,
            "Missing required config keys: #{missing_keys.join(', ')}"
    end

    private_class_method

    # Return a hash of the config for the provided +profile+ from
    # the first-existing file in the provided array of +config_files+.
    def self::profile_config(config_files, profile)
      config = nil
      config_files.each do |config_file|
        next unless File.exist?(File.expand_path(config_file))
        log.debug "found config file: #{config_file}"
        config = profile_from_file(config_file, profile)
        break
      end
      log.debug "Profile config: #{config}"
      config
    end

    # Given the pathname of a YAML or JSON +config_file+ and the name
    # of a config +profile+ within that file, load the file and
    # return a +Hash+ of the contents of that profile key.
    def self::profile_from_file(config_file, profile)
      content = YAML.load_file(File.expand_path(config_file))

      # Fetch options from file for the specified profile
      unless content.key?(profile)
        raise ConfigurationError,
              "Profile '#{profile}' not found in '#{config_file}"
      end
      profile_config = content[profile].symbolize_keys!

      # Merge the :auth_context keys into the top-level hash.
      profile_config.merge!(profile_config[:auth_context].symbolize_keys!)
      profile_config.delete_if { |k, _| k == :auth_context }
      profile_config
    end

    # Given a +command+, return an +array+ of
    # the key names from MANDATORY_CONFIG_KEYS for that command,
    # that are not present in the provided +config+
    def self::missing_keys_for_command(command, config)
      mandatory_keys = MANDATORY_CONFIG_KEYS[command] || []
      return [] if mandatory_keys.empty?
      return mandatory_keys unless config[command] &&
                                   config[command].is_a?(Hash)
      mandatory_keys - config[command].keys
    end
  end
end
