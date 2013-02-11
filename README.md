# Pushr

## Features

* Multi-App
* Multi-Provider ([APNS](https://github.com/tompesman/push-apns), [GCM](https://github.com/tompesman/push-gcm), [C2DM](https://github.com/tompesman/push-c2dm))
* Integrated feedback processing
* Rake task to cleanup the database
* Database for storage (no external dependencies)

## Installation

Add to your `GemFile`

    gem 'push-core'

and add the push provider to you Gemfile:

For __APNS__ (iOS: Apple Push Notification Services):

    gem 'push-apns'

For __C2DM__ (Android: Cloud to Device Messaging, deprecated by Google, not this gem):

    gem 'push-c2dm'

For __GCM__ (Android: Google Cloud Messaging):

    gem 'push-gcm'

And run `bundle install` to install the gems.

To generate the migration and the configuration files run:

    rails g push
    bundle exec rake db:migrate

## Configuration

The configuration is in the database and you add the configuration per push provider with the console (`rails c`):

APNS ([see](https://github.com/tompesman/push-core#generating-certificates)):
```ruby
Pushr::ConfigurationApns.create(app: 'app_name', connections: 2, enabled: true,
    certificate: File.read('certificate.pem'),
    feedback_poll: 60,
    sandbox: false)
```

The `skip_check_for_error` parameter is optional and can be set to `true` or `false`. If set to `true` the APNS service will not check for errors when sending messages. This option should be used in a production environment and improves performance. In production the errors are reported and handled by the feedback service.

C2DM ([see](https://developers.google.com/android/c2dm/)):
```ruby
Pushr::ConfigurationC2dm.create(app: 'app_name', connections: 2, enabled: true,
    email: '<email address here>',
    password: '<password here>')
```

GCM ([see](http://developer.android.com/guide/google/gcm/gs.html)):
```ruby
Pushr::ConfigurationGcm.create(app: 'app_name', connections: 2, enabled: true,
    key: '<api key here>')
```

You can have each provider per app_name and you can have more than one app_name. Use the instructions below to generate the certificate for the APNS provider. If you only want to prepare the database with the configurations, you can set the `enabled` switch to `false`. Only enabled configurations will be used by the daemon.

### Generating Certificates for APNS

1. Open up Keychain Access and select the `Certificates` category in the sidebar.
2. Expand the disclosure arrow next to the iOS Push Services certificate you want to export.
3. Select both the certificate and private key.
4. Right click and select `Export 2 items...`.
5. Save the file as `cert.p12`, make sure the File Format is `Personal Information Exchange (p12)`.
6. If you decide to set a password for your exported certificate, please read the Configuration section below.
7. Convert the certificate to a .pem, where `<environment>` should be `development` or `production`, depending on the certificate you exported.

    `openssl pkcs12 -nodes -clcerts -in cert.p12 -out <environment>.pem`

8. Move the .pem file somewhere where you can use the `File.read` to load the file in the database.

## Daemon

To start the daemon:

    bundle exec push <environment> <options>

Where `<environment>` is your Rails environment and `<options>` can be:

    -f, --foreground                 Run in the foreground. Log is not written.
    -p, --pid-file PATH              Path to write PID file. Relative to Rails root unless absolute.
    -P, --push-poll N                Frequency in seconds to check for new notifications. Default: 2.
    -n, --error-notification         Enables error notifications via Airbrake or Bugsnag.
    -F, --feedback-poll N            Frequency in seconds to check for feedback for the feedback processor. Default: 60. Use 0 to disable.
    -b, --feedback-processor PATH    Path to the feedback processor. Default: lib/push/feedback_processor.
    -v, --version                    Print this version of push.
    -h, --help                       You're looking at it.


## Sending notifications
APNS:
```ruby
Pushr::MessageApns.create(
    app: 'app_name',
    device: '<APNS device_token here>',
    alert: 'Hello World',
    sound: '1.aiff',
    badge: 1,
    expiry: 1.day.to_i,
    attributes_for_device: {key: 'MSG'})
```
C2DM:
```ruby
Pushr::MessageC2dm.create(
    app: 'app_name',
    device: '<C2DM registration_id here>',
    payload: { message: 'Hello World' },
    collapse_key: 'MSG')
```

GCM:
```ruby
Pushr::MessageGcm.create(
    app: 'app_name',
    device: '<GCM registration_id here>',
    payload: { message: 'Hello World' },
    collapse_key: 'MSG')
```

## Feedback processing

The push providers return feedback in various ways and these are captured and stored in the `push_feedback` table. The installer installs the `lib/push/feedback_processor.rb` file which is by default called every 60 seconds. In this file you can process the feedback which is different for every application.

## Maintenance

The push-core comes with a rake task to delete all the messages and feedback of the last 7 days or by the DAYS parameter.

    bundle exec rake push:clean DAYS=2

## Heroku

Push runs on Heroku with the following line in the `Procfile`.

    push: bundle exec push $RACK_ENV -f

## Prerequisites

* Rails 3.2.x
* Ruby 1.9.x

## Thanks

This project started as a fork of Ian Leitch [RAPNS](https://github.com/ileitch/rapns) project. The differences between this project and RAPNS is the support for C2DM and the modularity of the push providers.
