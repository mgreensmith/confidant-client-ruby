require 'gli'
require 'confidant/configurator'
require 'confidant/client'

module Confidant
  class CLI
    extend GLI::App

    program_desc 'Client for Confidant, an open source secret management system'
    version Confidant::VERSION


    ### Global configuration options

    # 'switch' options are booleans
    desc 'Prompt for an MFA token.'
    switch 'mfa'

    # 'flag' options take params

    desc 'Comma separated list of configuration files to use'
    flag 'config-files', default_value: Confidant::Configurator::DEFAULT_OPTS[:config_files].join(',')

    desc 'Configuration profile to use.'
    flag 'profile', default_value: Confidant::Configurator::DEFAULT_OPTS[:profile]

    desc 'Logging verbosity.'
    flag 'log-level', default_value: Confidant::Configurator::DEFAULT_OPTS[:log_level]

    desc 'URL of the confidant server.'
    flag ['u', 'url']

    desc 'Number of retries that should be attempted on confidant server errors.'
    flag 'retries'

    desc 'The KMS auth key to use. i.e. alias/authnz-production'
    flag ['k', 'auth-key']

    desc 'The token lifetime, in minutes.'
    flag ['l', 'token-lifetime']

    desc 'The version of the KMS auth token.'
    flag 'token-version'

    desc 'The IAM role or user to authenticate with. i.e. myservice-production or myuser'
    flag 'from'

    desc 'The IAM role name of confidant. i.e. confidant-production'
    flag 'to'

    desc 'The confidant user-type to authenticate as. i.e. user or service'
    flag 'user-type'

    desc 'Assume the specified IAM role.'
    flag 'assume-role'

    desc 'Use the specified region for authentication.'
    flag 'region'


    ### Commands

    desc 'Get credentials for a service'
    command :get_service do |c|

      c.desc 'The service to get.'
      c.flag 'service'

      c.action do |global_options,options,_|
        log.debug "Running get_service command"
        Confidant::Client.new(Confidant::Configurator.config).get_service

      end
    end


    ### Hooks

    pre do |global_options,command,options,_|
      Logging.logger.root.level = global_options['log-level'].to_sym

      opts = clean_opts(global_options)
      opts[command.name] = clean_opts(options)

      log.debug "Parsed CLI options: #{opts}"
      Confidant::Configurator.configure(opts, command.name)
    end


    # Try and clean up GLI's output into something useable.
    def self::clean_opts( gli_opts )
      # GLI provides String and Symbol keys for each flag/switch.
      # We want the String keys (because some of our flags have dashes)
      string_opts = gli_opts.select {|k, _| k.is_a?(String)}

      # Convert the dashes in key names to underscores and symbolize the keys.
      opts = {}
      string_opts.each_pair { |k, v| opts[k.gsub('-', '_').to_sym] = v }

      # Convert :config_files into an array.
      opts[:config_files] = opts[:config_files].split(',') if opts[:config_files]

      # Remove unneeded hash pairs:
      # - nil values: GLI returns a 'nil' default for non-specified flag-type opts
      # - false values: GLI returns a 'false' default for non-specified switch-type opts
      # Removing false values also removes GLI's :help and :version keys
      # - single-letter keys: these opts all have longer-form doppelgangers
      opts.delete_if { |k,v| v.nil? || v == false || k.length == 1 }

      #  Now, only defaulted and explicitly-specified options remain.
      return opts
    end

  end
end
