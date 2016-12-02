# Confidant

This is a client for [Confidant](https://lyft.github.io/confidant), an open source secret management service.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'confidant'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install confidant

## Configuration

This client supports the config file format of the [official Python client](https://lyft.github.io/confidant/basics/client/), but only in YAML format for now.

The client does not merge config from multiple files; it uses the profile configuration from the first file it finds.

CLI-provided options are merged with the configuration from file, with CLI options taking precedence.

## Usage

### CLI

```
NAME
    confidant - Client for Confidant, an open source secret management system

SYNOPSIS
    confidant [global options] command [command options] [arguments...]

VERSION
    0.1.0

GLOBAL OPTIONS
    --config-files=arg       - Comma separated list of configuration files to use (default: ~/.confidant,/etc/confidant/config)
    --from=arg               - The IAM role or user to authenticate with. i.e. myservice-production or myuser (default: none)
    --help                   - Show this message
    -k, --auth-key=arg       - The KMS auth key to use. i.e. alias/authnz-production (default: none)
    -l, --token-lifetime=arg - The token lifetime, in minutes. (default: none)
    --log-level=arg          - Logging verbosity. (default: info)
    --profile=arg            - Configuration profile to use. (default: default)
    --region=arg             - Use the specified region for authentication. (default: none)
    --to=arg                 - The IAM role name of confidant. i.e. confidant-production (default: none)
    --token-version=arg      - The version of the KMS auth token. (default: none)
    -u, --url=arg            - URL of the confidant server. (default: none)
    --user-type=arg          - The confidant user-type to authenticate as. i.e. user or service (default: none)
    --version                - Display the program version

COMMANDS
    get_service - Get credentials for a service
    help        - Shows a list of commands or help for one command
```

### Library Usage

```ruby
require 'confidant'

# Default values are the same as the CLI option defaults.
#
# Set subcommand names as top-level keys,
# with a hash value containing subcommand options.
#
# Options provided in this hash are merged with
# the profile configuration from the first available config file,
# with these options taking precedence.
Confidant.configure(
    auth_key: 'alias/authnz-production',
    from: 'myservice-production',
    to: 'confidant-production',
    get_service: {
        service: 'myservice-production'
    }
)

# An insufficient or malformed config will raise `Confidant::ConfigurationError`

# Fetch the credentials from the Confidant server
# for the preconfigured service, as a Hash.
credentials = Confidant::Client.get_service

# Or fetch credentials for a different service:
credentials = Confidant::Client.get_service('my-other-service')
```

### WARNING

This client is pre-alpha, and does not have feature parity with the official Python client!

#### Things that work

- The `get_service` CLI subcommand can fetch service credentials using a v2 KMS authentication token.

#### Things that have not been implemented yet

- Any other CLI subcommand, notably everything to do with server-blinded credentials
- JSON config files
- API retries/backoff
- The `confidant-format` formatter
- KMS v1 auth tokens
- Token caching
- Assuming an IAM role
- MFA tokens

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mgreensmith/confidant-client-ruby.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

