# Confidant

This is a client for [Confidant](https://lyft.github.io/confidant), an open source secret management service.

## Installation

    $ gem install confidant

## Configuration

This client is compatible with the config file format of the [official Python client](https://lyft.github.io/confidant/basics/client/); it should be a drop-in replacement.

The client will automatically look in `~/.confidant` and `/etc/confidant/config` for its configuration. Alternate config files can be specified via the `--config-files` (Ruby `:config_files`) option. The client does not merge config from multiple files; it expects to find a configuration block for the specified `--profile` (Ruby: `:profile`) in the first file it finds, with a default profile of `default`.

The following configuration is supported, with the listed defaults. Some defaults differ from the official Python client, namely `user_type` and `region`. Additionally, this client supports per-command configuration: options provided within config keys named for a CLI command (or `Confidant::Client` method) will be used as to configure that command.

```yaml
default:

  url: nil
  auth_key: nil

  # Unlike the official Python client, this client configures
  # these options in the top-level config.
  from: nil
  to: nil
  user_type: service

  # Provided for compatibility with the official Python client.
  # Any configured options in auth_context will be flattened into
  # the top-level config, and will override provided top-level values.
  auth_context:
    from: nil
    to: nil
    user_type: service

  token_lifetime: 10
  token_version: 2

  region: us-east-1

  # Example of per-command configuration for the get_service command
  # get_service:
  #   service: nil

  # Not yet implemented in this client:
  # retries: 0
  # backoff: 1
  # token_cache_file: '/run/confidant/confidant_token'
  # assume_role: nil
```

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
    show_config - Show the current config
```

## Library Usage

Require the client.

```ruby
require 'confidant'
```

Configure the library via `Confidant.configure`.

An insufficiently-specified config, or any errors during configuration, will raise `Confidant::ConfigurationError`

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

# Or choose to use options from config files only:
Confidant.configure
```

Create a new `Confidant::Client`, and fetch credentials from the Confidant server. JSON responses from the server are returned as Ruby `Hash`es.

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

