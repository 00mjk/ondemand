# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
- Added example YAML configuration file that can be copied to the global
  location `/etc/ood/config/apps/shell/config.yml` to be read by app.
  [#43](https://github.com/OSC/ood-shell/pull/43)
- Added support to read local environment variable file `.env.local`.

### Changed
- Reads environment variables from global location
  `/etc/ood/config/apps/shell/env`.
  [#42](https://github.com/OSC/ood-shell/issues/42)

### Deprecated
- Deprecating old environment variable file `.env` located underneath the app.

## [1.2.4] - 2017-10-20
### Changed
- Updated hterm from 1.61 to 1.73.
  [#41](https://github.com/OSC/ood-shell/issues/41)

## [1.2.3] - 2017-07-10
### Changed
- Changed the `CHANGELOG.md` formatting.

### Fixed
- Warn user if fail to establish websocket connection.
  [#38](https://github.com/OSC/ood-shell/issues/38)

## 1.2.2 - 2017-05-30
### Fixed
- Fix to handle multibyte UTF-8 URI decoding.
- Warn users if they try to close an active terminal.
- Warn users when their websocket connection is terminated.

[Unreleased]: https://github.com/OSC/ood-shell/compare/v1.2.4...HEAD
[1.2.4]: https://github.com/OSC/ood-shell/compare/v1.2.3...v1.2.4
[1.2.3]: https://github.com/OSC/ood-shell/compare/v1.2.2...v1.2.3
