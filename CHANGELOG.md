<!-- markdownlint-disable MD024 -->
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org).

## [v4.1.0](https://github.com/puppetlabs/device_manager/tree/v4.1.0) - 2023-10-19

[Full Changelog](https://github.com/puppetlabs/device_manager/compare/v4.0.0...v4.1.0)

### Added

- pdksync - (MAINT) - Allow Stdlib 9.x [#103](https://github.com/puppetlabs/device_manager/pull/103) ([LukasAud](https://github.com/LukasAud))

## [v4.0.0](https://github.com/puppetlabs/device_manager/tree/v4.0.0) - 2022-05-23

[Full Changelog](https://github.com/puppetlabs/device_manager/compare/v3.1.0...v4.0.0)

### Changed
- (maint) Remove support for Puppet 5 [#91](https://github.com/puppetlabs/device_manager/pull/91) ([david22swan](https://github.com/david22swan))

### Added

- Update for Puppet 7 compability [#86](https://github.com/puppetlabs/device_manager/pull/86) ([tkishel](https://github.com/tkishel))

## [v3.1.0](https://github.com/puppetlabs/device_manager/tree/v3.1.0) - 2020-12-02

[Full Changelog](https://github.com/puppetlabs/device_manager/compare/v3.0.1...v3.1.0)

### Added

- (MODULES-9191) implement configurable run_user per device [#64](https://github.com/puppetlabs/device_manager/pull/64) ([tkishel](https://github.com/tkishel))

### Fixed

- run_user and run_group for device_manager::devices [#76](https://github.com/puppetlabs/device_manager/pull/76) ([bFekete](https://github.com/bFekete))
- (maint) confine and variables and ensure [#74](https://github.com/puppetlabs/device_manager/pull/74) ([tkishel](https://github.com/tkishel))
- Manage devices' config folder [#73](https://github.com/puppetlabs/device_manager/pull/73) ([JonasVerhofste](https://github.com/JonasVerhofste))
- Do not require aio_agent_version to be present [#66](https://github.com/puppetlabs/device_manager/pull/66) ([fizmat](https://github.com/fizmat))
- (MODULES-9628, PUP-8736) don't purge device certificates on new puppet versions (3.0.1 hotfix) [#58](https://github.com/puppetlabs/device_manager/pull/58) ([DavidS](https://github.com/DavidS))

## [v3.0.1](https://github.com/puppetlabs/device_manager/tree/v3.0.1) - 2019-08-14

[Full Changelog](https://github.com/puppetlabs/device_manager/compare/v3.0.0...v3.0.1)

### Added

- (MODULES-9191) support a non-root user [#46](https://github.com/puppetlabs/device_manager/pull/46) ([tkishel](https://github.com/tkishel))

## [v3.0.0](https://github.com/puppetlabs/device_manager/tree/v3.0.0) - 2019-06-11

[Full Changelog](https://github.com/puppetlabs/device_manager/compare/v2.7.1...v3.0.0)

### Fixed

- (maint) Relax version requirement for concat [#49](https://github.com/puppetlabs/device_manager/pull/49) ([DavidS](https://github.com/DavidS))
- (FM-8238, FM-8137) Dependency fixes [#48](https://github.com/puppetlabs/device_manager/pull/48) ([DavidS](https://github.com/DavidS))

## [v2.7.1](https://github.com/puppetlabs/device_manager/tree/v2.7.1) - 2019-04-10

[Full Changelog](https://github.com/puppetlabs/device_manager/compare/2.7.0...v2.7.1)

### Fixed

- (maint) removing the aio_agent_version fact check [#41](https://github.com/puppetlabs/device_manager/pull/41) ([Thomas-Franklin](https://github.com/Thomas-Franklin))
- Tighter version bounding on puppetlabs/hocon [#40](https://github.com/puppetlabs/device_manager/pull/40) ([rnelson0](https://github.com/rnelson0))
- Fix build issues on Jenkins [#39](https://github.com/puppetlabs/device_manager/pull/39) ([da-ar](https://github.com/da-ar))

## [2.7.0](https://github.com/puppetlabs/device_manager/tree/2.7.0) - 2018-10-02

[Full Changelog](https://github.com/puppetlabs/device_manager/compare/2.6.0...2.7.0)

### Added

- (FM-7230) Specify defaults for multiple devices when using Hiera or Classifier [#24](https://github.com/puppetlabs/device_manager/pull/24) ([tkishel](https://github.com/tkishel))
- (FM-7148) logdest scheduled runs to system log [#16](https://github.com/puppetlabs/device_manager/pull/16) ([tkishel](https://github.com/tkishel))
- (FM 7115) return device certificates with task results [#15](https://github.com/puppetlabs/device_manager/pull/15) ([tkishel](https://github.com/tkishel))

### Fixed

- CVE-2018-11748 (FM-7258) Update device config file permissions [#32](https://github.com/puppetlabs/device_manager/pull/32) ([willmeek](https://github.com/willmeek))
- (FM-7383) allow device manager to work with Puppet 6 [#27](https://github.com/puppetlabs/device_manager/pull/27) ([Thomas-Franklin](https://github.com/Thomas-Franklin))
- Pass through credentials from device_manager::devices [#21](https://github.com/puppetlabs/device_manager/pull/21) ([DavidS](https://github.com/DavidS))
- (FM-7114) purge conf devices directory [#18](https://github.com/puppetlabs/device_manager/pull/18) ([tkishel](https://github.com/tkishel))

## [2.6.0](https://github.com/puppetlabs/device_manager/tree/2.6.0) - 2018-06-01

[Full Changelog](https://github.com/puppetlabs/device_manager/compare/2.5.0...2.6.0)

## [2.5.0](https://github.com/puppetlabs/device_manager/tree/2.5.0) - 2018-05-31

[Full Changelog](https://github.com/puppetlabs/device_manager/compare/077dead6c0e24a15e1227db295d17d3af583c2f0...2.5.0)
