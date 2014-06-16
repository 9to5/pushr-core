# Pushr

Please note: We're in the process of updating this gem. The current code is not yet stable. Please contact us if you
want to test or contribute to this project.

[![Build Status](https://travis-ci.org/9to5/pushr-core.svg?branch=master)](https://travis-ci.org/9to5/pushr-core)
[![Code Climate](https://codeclimate.com/github/9to5/pushr-core.png)](https://codeclimate.com/github/9to5/pushr-core)
[![Coverage Status](https://coveralls.io/repos/9to5/pushr-core/badge.png)](https://coveralls.io/r/9to5/pushr-core)

## Features

* Lightening fast push notification delivery
* Redis for queueing
* Multi-App
* Multi-Provider ([APNS](https://github.com/9to5/pushr-apns), [GCM](https://github.com/9to5/pushr-gcm))
* Integrated feedback processing
* Multi-process

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
Pushr::ConfigurationApns.new(app: 'app_name', connections: 2, enabled: true,
    certificate: File.read('certificate.pem'), sandbox: false, skip_check_for_error: false).save
```

The `skip_check_for_error` parameter can be set to `true` or `false`. If set to `true` the APNS service
will not check for errors when sending messages. This option should be used in a production environment and improves
performance. In production the errors are reported and handled by the feedback service. Please note that if you use
sandbox devices in your production environment you should not set `skip_check_for_error = true`.

APNS Feedback:
```ruby
Pushr::ConfigurationApnsFeedback.new(app: 'app_name', connections: 1, enabled: true,
    feedback_poll: 60).save
```

Use this configuration to let a thread check for feedback on all APNS Configurations. It checks every `feedback_poll` in seconds.

GCM ([see](http://developer.android.com/guide/google/gcm/gs.html)):
```ruby
Pushr::ConfigurationGcm.new(app: 'app_name', connections: 2, enabled: true, api: '<api key here>').save
```

You can have each provider per app_name and you can have more than one app_name. Use the instructions below to generate
the certificate for the APNS provider. If you only want to prepare the database with the configurations, you can set the
`enabled` switch to `false`. Only enabled configurations will be used by the daemon.

### YAML File

If a YAML file is used for configuration, it needs to follow the structure of the example below, and may contain only the desired sections.

The certificates will be read from files. For security reasons, you might not want to check-in the certificate files into your source code repository.

If no absolute path is given of the PEM files, the location is assumed to be relative to the location of the YAML file.

The following example of a YAML configuration file can be found under `./lib/generators/templates/pushr.yml`.


```
# Configurations for all Pushr Gems
---

# Android Messaging:

- type: Pushr::ConfigurationGcm
  app: gcm-development
  enabled: true
  connections: 1
  api: your-api-key-here


# Feedback Service for all APNS Connections:

- type: Pushr::ConfigurationApnsFeedback
  app: apns-feedback
  enabled: true
  connections: 1
  feedback_poll: 300 # seconds

# Apple Messaging:

- type: Pushr::ConfigurationApns
  app: ios-development
  enabled: true
  connections: 1
  skip_check_for_error: false
  sandbox: true
  certificate: filename.pem

- type: Pushr::ConfigurationApns
  app: ios-development
  enabled: true
  connections: 1
#    skip_check_for_error: true
  sandbox: true
  certificate: pushr/ios-development.pem

- type: Pushr::ConfigurationApns
  app: ios-production
  enabled: true
  connections: 1
#    skip_check_for_error: true
  sandbox: false
  certificate: pushr/ios-production.pem

- type: Pushr::ConfigurationApns
  app: ios-beta
  enabled: true
  connections: 1
#    skip_check_for_error: true
  sandbox: true
  certificate: pushr/ios-beta.pem

- type: Pushr::ConfigurationApns
  app: ios-enterprise
  enabled: true
  connections: 1
#    skip_check_for_error: true
  sandbox: false
  certificate: pushr/ios-enterprise.pem

```

If you are using `Pushr` with Rails, add this to your `application.rb` file:

      Pushr::Core.configuration_file = File.join(Rails.env , 'config/pushr/config.yaml')

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
    -p, --pid-file PATH              Path to write PID file. Relative to Rails root unless absolute.
    -b, --feedback-processor PATH    Path to the feedback processor. Default: lib/push/feedback_processor.
    -c, --configuration FILE         Read the configuration from this YAML file (optional)
    -v, --version                    Print this version of push.
    -h, --help                       You're looking at it.

## Sending notifications

APNS:
```ruby
Pushr::MessageApns.new(
    app: 'app_name',
    device: '<APNS device_token here>',
    alert: 'Hello World',
    sound: '1.aiff',
    badge: 1,
    expiry: 1.day.from_now.to_i,
    attributes_for_device: {key: 'MSG'},
    priority: 10,
    content_available: 1).save
```


Silent Push Notification via APNS:

```ruby
Push::MessageApns.create(
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
Pushr::MessageGcm.new(
    app: 'app_name',
    registration_ids: ['<GCM registration_id here>', '<GCM registration_id here>'],
    notification_key: 'notification_key_name',
    delay_while_idle: true,
    data: { message: 'Hello World' },
    time_to_live: 24 * 60 * 60,
    restricted_package_name: 'com.example.gcm',
    dry_run: false,
    collapse_key: 'MSG').save
```


## Feedback processing

The push providers return feedback in various ways and these are captured and stored in the `push_feedback` table. The
installer installs the `lib/push/feedback_processor.rb` file which is by default called every 60 seconds. In this file
you can process the feedback which is different for every application.

## Tracking your own Message IDs

If you have your own message-IDs for notifications in your system and want to track them throughout the message delivery, so they show up in all the logs you can add this during message creation:

    external_id: your_external_id_here

You can also set the prefix under which your message ID will show up in the logs:

    Pushr::Core.external_id_tag = "MyID"   # will pre-fix the above message ID with this string

This can be useful if you want to automatically ingest your log files for analytics.

Furthermore you can hand your message-ID to the mobile device, so it can either log it, or the mobile device can return a call to an API endpoint to record the time the message was actually received. This way you can measure end-to-end delivery times. This works best for silent push notifications in APNS.

## Heroku

Push runs on Heroku with the following line in the `Procfile`.

    pushr: bundle exec pushr -f

## Prerequisites

* Ruby 1.9.3, 2.0, 2.1
* Redis
