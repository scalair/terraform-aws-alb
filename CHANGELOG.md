# Changelog

## v2.0.0 - 2021-02-02

### Changed

- BREAKING CHANGE: alb module refactoring and update to the latest version (5.0+)
- BREAKING CHANGE: use security-group module instead of resource
- BREAKING CHANGE: remove log bucket creation

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
