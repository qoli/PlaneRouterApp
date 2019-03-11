#!/usr/bin/env ruby

require 'houston'

# Environment variables are automatically read, or can be overridden by any specified options. You can also
# conveniently use `Houston::Client.development` or `Houston::Client.production`.
APN = Houston::Client.development
APN.certificate = File.read('/Users/qoli/Documents/Xcode/Router/development_com.qoli.Router.pem')

# An example of the token sent back when a device registers for notifications
token = '<5ee5ef7cd20cbba0a23df1bc6906ec0d9a2631b2757d08ce6d4b9cf4c2cdbd6f>'

# Create a notification that alerts a message to the user, plays a sound, and sets the badge on the app
notification = Houston::Notification.new(device: token)
notification.alert = 'Hello, World!'

# Notifications can also change the badge count, have a custom sound, have a category identifier, indicate available Newsstand content, or pass along arbitrary data.
notification.badge = 0
notification.sound = 'sosumi.aiff'
notification.category = 'INVITE_CATEGORY'
notification.content_available = true
notification.mutable_content = true
notification.thread_id = 'notify-team-ios'

# And... sent! That's all it takes.
APN.push(notification)


# [15:50:54]: You already have an existing push certificate, but a new one will be created since the --force option has been set.
# [15:50:54]: Creating a new push certificate for app 'com.qoli.Router'.
# [15:50:57]: Private key: /Users/qoli/Documents/Xcode/Router/production_com.qoli.Router.pkey
# [15:50:57]: p12 certificate: /Users/qoli/Documents/Xcode/Router/production_com.qoli.Router.p12
# [15:50:57]: PEM: /Users/qoli/Documents/Xcode/Router/production_com.qoli.Router.pem

# [15:51:37]: You already have an existing push certificate, but a new one will be created since the --force option has been set.
# [15:51:37]: Creating a new push certificate for app 'com.qoli.Router'.
# [15:51:40]: Private key: /Users/qoli/Documents/Xcode/Router/development_com.qoli.Router.pkey
# [15:51:40]: p12 certificate: /Users/qoli/Documents/Xcode/Router/development_com.qoli.Router.p12
# [15:51:40]: PEM: /Users/qoli/Documents/Xcode/Router/development_com.qoli.Router.pem