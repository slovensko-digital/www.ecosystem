# Be sure to restart your server when you modify this file.
#
# This file contains migration options to ease your Rails 5.2 upgrade.
#
# Once upgraded flip defaults one by one to migrate to the new default.
#
# Read the Guide for Upgrading Ruby on Rails for more info on each option.

# Use AES-256-GCM authenticated encryption for encrypted cookies.
# Also, embed cookie expiry in signed or encrypted cookies for increased security.
#
# This option is not backwards compatible with earlier Rails versions.
# It's best enabled when your entire app is migrated and stable on 5.2.
#
# Existing cookies will be converted on read then written with the new scheme.
# Rails.application.config.action_dispatch.use_authenticated_cookie_encryption = true
