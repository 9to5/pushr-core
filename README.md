# Pushr

[![Build Status](https://travis-ci.org/9to5/pushr-core.svg?branch=master)](https://travis-ci.org/9to5/pushr-core)
[![Code Climate](https://codeclimate.com/github/9to5/pushr-core.png)](https://codeclimate.com/github/9to5/pushr-core)
[![Coverage Status](https://coveralls.io/repos/9to5/pushr-core/badge.png)](https://coveralls.io/r/9to5/pushr-core)

## Features

* Lightning fast push notification delivery
* Redis for queueing
* Redis or YAML for configuration
* Multi-App
* Multi-Provider ([APNS](https://github.com/9to5/pushr-apns), [GCM](https://github.com/9to5/pushr-gcm))
* Multi-process
* Integrated feedback processing

## Installation

Add to your `Gemfile`

    gem 'pushr-core'

and add the push provider to you Gemfile:

For __APNS__ (iOS: Apple Push Notification Services):

    gem 'pushr-apns'

For __GCM__ (Android: Google Cloud Messaging):

    gem 'pushr-gcm'

And run `bundle install` to install the gems.

## Configuration

### Via Redis or YAML File

The configuration of Pushr can either be stored in Redis or in a YAML file. **The default is Redis.**

If you want to use a YAML file, you need to specify it via the `-c` option of the `pushr` daemon.
Note that this will also override any existing Redis configuration.
APNS certificates can be loaded from file. If a relative file name is given, it's assumed to be relative to the same path as the YAML config file.

### Redis

By default the gem tries to connect to a Redis instance at localhost. If you define the `PUSHR_URL` environment variable
it will use that. The configuration is stored in Redis and you add the configuration per push provider with the console
(`bundle console`):

APNS ([see](https://github.com/9to5/pushr-core#generating-certificates)):
```ruby
Pushr::ConfigurationApns.create(app: 'app_name', connections: 2, enabled: true,
    certificate: File.read('certificate.pem'), sandbox: false, skip_check_for_error: false)
```

The `skip_check_for_error` parameter can be set to `true` or `false`. If set to `true` the APNS service
will not check for errors when sending messages. This option should be used in a production environment and improves
performance. In production the errors are reported and handled by the feedback service. Please note that if you use
sandbox devices in your production environment you should not set `skip_check_for_error = true`.

APNS Feedback:
```ruby
Pushr::ConfigurationApnsFeedback.create(app: 'app_name', connections: 1, enabled: true,
    feedback_poll: 60)
```

Use this configuration to let a thread check for feedback on all APNS Configurations. It checks every `feedback_poll` in seconds.
There should be only one instance of this configuration type.

GCM ([see](http://developer.android.com/guide/google/gcm/gs.html)):
```ruby
Pushr::ConfigurationGcm.create(app: 'app_name', connections: 2, enabled: true, api: '<api key here>')
```

You can have each provider per app_name and you can have more than one app_name. Use the instructions below to generate
the certificate for the APNS provider. If you only want to prepare the database with the configurations, you can set the
`enabled` switch to `false`. Only enabled configurations will be used by the daemon.

### YAML File

If a YAML file is used for configuration, it needs to follow the structure of the example below, and may contain only the
desired sections. The certificates will be read from files. For security reasons, you might not want to check-in the certificate
files into your source code repository.

If no absolute path is given of the PEM files, the location is assumed to be relative to the location of the YAML file. An example
of a YAML configuration file can be found under `./lib/generators/templates/pushr.yml`.

If you are using `Pushr` with Rails, add this to your `config/initializers/pushr.rb` file:

```ruby
Pushr::Core.configure do |config|
  config.configuration_file = File.join(Rails.root , 'config/pushr/config.yaml')
end
```

### Generating Certificates for APNS

1. Open up Keychain Access and select the `Certificates` category in the sidebar.
2. Expand the disclosure arrow next to the iOS Push Services certificate you want to export.
3. Select both the certificate and private key.
4. Right click and select `Export 2 items...`.
5. Save the file as `cert.p12`, make sure the File Format is `Personal Information Exchange (p12)`.
6. If you decide to set a password for your exported certificate, please read the Configuration section below.
7. Convert the certificate to a .pem, where `<environment>` should be `development` or `production`, depending on the
certificate you exported.

    `openssl pkcs12 -nodes -clcerts -in cert.p12 -out <environment>.pem`

8. Move the .pem file somewhere where you can use the `File.read` to load the file in the database.

## Daemon

To start the daemon:

    bundle exec pushr <options>

Where `<options>` can be:

    -f, --foreground                 Run in the foreground. Log is not written.
    -c, --configuration FILE         Read the configuration from this YAML file
    -j, --json JSON                  Read the configuration from provided JSON
    -a, --redis-json JSON            Read redis configuration from JSON. For more info check redis gem documentation
    -o, --redis-host HOST            Hostname of redis instance
    -r, --redis-port PORT            Port of redis instance
    -n, --redis-namespace NAMESPACE  Namespace on redis connection
    -d, --redis-db DB                Redis database number
    -p, --pid-file PATH              Path to write PID file. Relative to current directory unless absolute.
    -b, --feedback-processor PATH    Path to the feedback processor. Default: none. Example: 'lib/pushr/feedback_processor'
    -s, --stats-processor PATH       Path to the stats processor. Default: none. Example: 'lib/pushr/stats_processor'
    -v, --version                    Print this version of pushr.
    -h, --help                       You're looking at it.

## Sending notifications

Use the `new` and `save` methods to create a message or use the `create` and `create!` methods. These methods are
similar to the ActiveRecord model methods.

APNS:
```ruby
Pushr::MessageApns.create(
    app: 'app_name',                      # required: String, the name of the configuration
    device: '<APNS device_token here>',   # required: String, token of the device
    expiry: 1.day.from_now.to_i,          # required: Integer, A UNIX epoch date expressed in seconds
    priority: 10,                         # required: Integer, 10 or 5 (should be 10 if message includes an alert, sound or badge)
    alert: 'Hello World',                 # optional: String or Hash, read APNS documentation for more information
    sound: '1.aiff',                      # optional: String, sound to play
    badge: 1,                             # optional: Integer, display badge on homescreen
    attributes_for_device: {key: 'MSG'},  # optional: Hash, send additional parameters
    content_available: 1)                 # optional: Integer, 1 if device should be notified if new content is available
```


Silent Push Notification via APNS:

```ruby
Pushr::MessageApns.create(
    app: 'app_name',
    device: '<APNS device_token here>',
    alert: nil,
    sound: nil,
    badge: 1,
    content_available: 1,   # see footnote
    expiry: 1.day.to_i,
    attributes_for_device: nil)
```

Use `content_available: 1` if the iOS device should start your app upon receiving the silent push notification.


GCM:
```ruby
Pushr::MessageGcm.create(
    app: 'app_name',                                # required: String, the name of the configuration
    registration_ids: ['<registration_id>', '...'], # required: Array of registration ids
    notification_key: 'notification_key_name',      # optional: String, Use with User Notifications
    delay_while_idle: true,                         # optional: Boolean, message is received if device is active
    data: { message: 'Hello World' },               # optional: Hash, contains information for the app
    time_to_live: 24 * 60 * 60,                     # optional: Integer, in seconds how long the message will be stored
    restricted_package_name: 'com.example.gcm',     # optional: String, message will only be received with this package name
    dry_run: false,                                 # optional: Boolean, do not actually deliver the message to the app
    collapse_key: 'MSG')                            # optional: String, messages with the same key can be collapsed into one
```

## Feedback processing

The push providers return feedback in various ways and these are captured and stored in the `push_feedback` table. The
installer installs the `lib/pushr/feedback_processor.rb` file which is by default called every 60 seconds. In this file
you can process the feedback which is different for every application.

## Tracking your own Message IDs

If you have your own message-IDs for notifications in your system and want to track them throughout the message delivery, so they
show up in all the logs you can add this during message creation:
```ruby
  external_id: your_external_id_here
```

You can also set the prefix under which your message ID will show up in the logs:
```ruby
Pushr::Core.configure do |config|
  config.external_id_tag = 'MyID' # will pre-fix the above message ID with this string
end
```

This can be useful if you want to automatically ingest your log files for analytics.

Furthermore you can hand your message-ID to the mobile device, so it can either log it, or the mobile device can return a call to
an API endpoint to record the time the message was actually received. This way you can measure end-to-end delivery times. This
works best for silent push notifications in APNS.

## Heroku

Push runs on Heroku with the following line in the `Procfile`.

    pushr: bundle exec pushr -f

## Prerequisites

* Ruby 1.9.3, 2.0, 2.1
* Redis
