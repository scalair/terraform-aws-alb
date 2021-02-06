# Changelog

## v2.0.0 - 2021-02-05

### Changed

*BREAKING CHANGES:*

- Update to the latest version of ALB module (5.0+)
- Use security-group module instead of resource
- Remove log bucket creation
- Add listener rules for protection
- Refactor target groups
- Add example in README

## v1.2.0 - 2020-11-26

### Changed

- BREAKING CHANGE: remove region from `aws_s3_bucket` resource block for use with AWS provider v3

## v1.1.1 - 2019-11-14

### Fixed

- Allow ALL for egress

## v1.1.0 - 2019-11-14

### Added

- S3 bucket for ALB access logs

## v1.0.0 - 2019-10-23

### Added

- Initial commit
