require 'gli'

require 'confidant/configurator'

module Confidant
  class CLI
    extend GLI::App

    program_desc 'Client for Confidant, an open source secret management system'
    version Confidant::VERSION


    ### Global configuration options

    DEFAULTS = Confidant::Configurator::DEFAULTS

    desc 'Comma separated list of configuration files to use'
    flag :config_files, default_value: DEFAULTS[:config_files].join(',')

    desc 'Configuration profile to use.'
    flag :profile, default_value: DEFAULTS[:profile]

    desc 'URL of the confidant server.'
    flag [:u, :url], default_value: DEFAULTS[:url]

    desc 'Number of retries that should be attempted on confidant server errors.'
    flag :retries, default_value: DEFAULTS[:retries]

    desc 'The KMS auth key to use. i.e. alias/authnz-production'
    flag [:k, :auth_key], default_value: DEFAULTS[:auth_key]

    desc 'The token lifetime, in minutes.'
    flag [:l, :token_lifetime], default_value: DEFAULTS[:token_lifetime]

    desc 'The version of the KMS auth token.'
    flag :token_version, default_value: DEFAULTS[:token_version]

    desc 'The IAM role or user to authenticate with. i.e. myservice-production or myuser'
    flag :from, default_value: DEFAULTS[:from]

    desc 'The IAM role name of confidant. i.e. confidant-production'
    flag :to, default_value: DEFAULTS[:to]

    desc 'The confidant user-type to authenticate as. i.e. user or service'
    flag :user_type, default_value: DEFAULTS[:user_type]

    desc 'Prompt for an MFA token.'
    switch :mfa, default_value: DEFAULTS[:mfa]

    desc 'Assume the specified IAM role.'
    flag :assume_role, default_value: DEFAULTS[:assume_role]

    desc 'Use the specified region for authentication.'
    flag :region, default_value: DEFAULTS[:region]

    desc 'Logging verbosity.'
    flag :log_level, default_value: DEFAULTS[:log_level]


    ### Commands

    desc 'Get credentials for a service'
    command :get_service do |c|

      c.desc 'The service to get.'
      c.flag :service, default_value: DEFAULTS[:get_service][:service]

      c.action do |global_options,options,_|


        puts "get_service command ran"
      end
    end


    ### Hooks

    pre do |global_options,command,options,_|

      cli_opts = global_options.select { |k, _| k.is_a? Symbol }
      cli_opts[command.name] = options.select { |k, _| k.is_a? Symbol }

      # Convert :config_files into an array.
      cli_opts[:config_files] = cli_opts[:config_files].split(',')

      require 'pp'
      pp cli_opts


      true
    end

  end
end


# desc 'Describe some switch here'
# switch [:s,:switch]

# desc 'Describe some flag here'
# default_value 'the default'
# arg_name 'The name of the argument'
# flag [:f,:flagname]

# desc 'Describe get_service here'
# arg_name 'Describe arguments to get_service here'
# command :get_service do |c|
#   c.desc 'Describe a switch to get_service'
#   c.switch :s

#   c.desc 'Describe a flag to get_service'
#   c.default_value 'default'
#   c.flag :f
#   c.action do |global_options,options,args|

#     # Your command logic here
     
#     # If you have any errors, just raise them
#     # raise "that command made no sense"

#     puts "get_service command ran"
#   end
# end

# pre do |global,command,options,args|
#   # Pre logic here
#   # Return true to proceed; false to abort and not call the
#   # chosen command
#   # Use skips_pre before a command to skip this block
#   # on that command only
#   true
# end

# post do |global,command,options,args|
#   # Post logic here
#   # Use skips_post before a command to skip this
#   # block on that command only
# end

# on_error do |exception|
#   # Error logic here
#   # return false to skip default error handling
#   true
# end
