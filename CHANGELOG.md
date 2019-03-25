# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## 0.2.2 - Unreleased
### Changed
  - Upgrade baseimage to light-baseimage:1.1.2
  - log to /dev/stdout
  - Update postfix config

## 0.2.1 - 2017-12-15
### Added 
  - Add POSTFIX_GATEWAY_HOSTNAME, POSTFIX_GATEWAY_BEST_MX_TRANSPORT and POSTFIX_GATEWAY_LOG_TO environment variables

### Changed
  - Update postfix chroot conf
  - Upgrade baseimage to light-baseimage:1.1.1

### Removed
  - POSTFIX_GATEWAY_LOG_TO_STDOUT environment variable

## 0.2.0 - 2017-07-19
### Changed
  - Upgrade baseimage to light-baseimage:1.1.0 (debian stretch)

## 0.1.0 - 2017-03-25
Initial release

[0.2.2]: https://github.com/osixia/docker-postfix-gateway/compare/v0.2.1...v0.2.2
[0.2.1]: https://github.com/osixia/docker-postfix-gateway/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/osixia/docker-postfix-gateway/compare/v0.1.0...v0.2.0