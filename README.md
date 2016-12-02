# Confidant

This is a client for [Confidant](https://lyft.github.io/confidant), an open source secret management service.

## Installation

    $ gem install confidant

## Configuration

This client supports the config file format of the [official Python client](https://lyft.github.io/confidant/basics/client/).

The client does not merge config from multiple files; it expects to find a configuraton block for the specified `profile` in the first file it finds.

When using the CLI, CLI-provided options are merged with config file options, with CLI options taking precedence.

When using the client as a Ruby library, options passed as parameters to `Confidant.configure` are merged with config file options, with parameter options taking precedence.

## CLI Usage

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

## Library Usage

Require the client.

```ruby
require 'confidant'
```

Configure the `Confidant` module with some/all/no config options. Default values are the same as the CLI option defaults.

Key names match the long-form CLI option flag names, as symbols, with dashes becoming underscores. e.g. `--log-level` is `:log_level`.

For command-level options, provide the command name as a top-level key, with a hash value containing options for that command. e.g. `get_service: { service: 'myservice' }`

Options provided in this hash are merged with any config options found in the specified `:profile` section of the first-existing file from `:config_files`, with method options taking precedence over file options.

An insufficient or malformed config, or a missing `:profile` section in a config file, will raise `Confidant::ConfigurationError`

```ruby
# Provide a few explicit options:
Confidant.configure(
    auth_key: 'alias/authnz-production',
    from: 'myservice-production',
    to: 'confidant-production',
    get_service: {
        service: 'myservice-production'
    }
)

# Or just use options from config files:
Confidant.configure
```

Create a new `Confidant::Client`, and fetch credentials from the Confidant server. JSON responses from the server are converted to Ruby `Hash`es.

```ruby
client = Confidant::Client.new

credentials = client.get_service('myservice-production')

# If a service name was preconfigured,
# i.e. `get_service: { service: 'myservice' }` exists in config,
# the service name parameter can be excluded:
credentials = client.get_service
```

### WARNING

This client is pre-alpha, and does not have feature parity with the official Python client!

#### Things that work

- The `get_service` CLI command (`Client.get_service`) can fetch service credentials from a Confidant server using a v2 KMS authentication token.
- All currently-available CLI options are correctly configurable.

#### Things that have not been implemented yet

- Any other CLI command, notably everything to do with server-blinded credentials
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

