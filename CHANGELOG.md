# Changelog
All notable changes to this project will be documented in this file.

## [Unreleased]

### Fixed

- Sanitize user input for account string.
  [#233](https://github.com/OSC/ood-myjobs/issues/233)

## [v2.5.0] - 2017-07-12

### Added

- Support for PBS Pro and basic support for LSF 9.1 via update to ood_core gem

## [v2.4.2] - 2017-07-10

### Added

- Add warning and prevent submission if host is invalid

### Changed

- Display a cluster's metadata title instead of titleized id
- Fix bug where new template path isn't blank
- Redirect user to new templates page on cancel
- Fix a bug when requesting data for a workflow with an unassigned batch_host

## [v2.4.1] - 2017-06-05

- Fix bug in `bin/setup` that crashes when `OOD_PORTAL` is set but not
  `OOD_SITE`

## [v2.4.0] - 2017-05-26

- Allow user to enter relative path names as template source
- Allow a user to create a new workflow from a path
- Allow user to resubmit a completed/failed job
- Display the script name associated with a workflow
- Add prompt to null selectpicker option
- Wrap long names that break out of containers
- UI enhancements

## [v2.3.4] - 2017-05-15

- Terminal button now links to appropriate host instead of default
- Update to OOD Appkit 1.0.1
- Alert if no valid hosts are available
- Hide row of job creation buttons if no submit hosts
- UI enhancements


[Unreleased]: https://github.com/OSC/ood-myjobs/compare/v2.5.0...HEAD
[v2.5.0]: https://github.com/OSC/ood-myjobs/compare/v2.4.2...v2.5.0
[v2.4.2]: https://github.com/OSC/ood-myjobs/compare/v2.4.1...v2.4.2
[v2.4.1]: https://github.com/OSC/ood-myjobs/compare/v2.4.0...v2.4.1
[v2.4.0]: https://github.com/OSC/ood-myjobs/compare/v2.3.4...v2.4.0
[v2.3.4]: https://github.com/OSC/ood-myjobs/compare/v1.0.0...v2.3.4
