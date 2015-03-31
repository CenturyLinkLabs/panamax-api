# Changelog
All notable changes to this project will be documented in this file.

0.3.1 - 2015-3-31
-------------------
### Updated
- Updated base image

0.3.0 - 2015-3-19
-------------------
### Updated
- Always send the refresh flag to Dray (#282)
- Use New Fleet API: v1.1.0

0.2.16 - 2015-3-9
-------------------
### Updated
- Dray integration (sends the new delimiters - #b89d423c167d7425d95eb75107a95031adabdec6)
- Template Documentation

0.2.15 - 2015-2-25
-------------------
### Updated
- AWS Fleet job creation template (#278)
- Moved to 0.3.0 of panamax-ruby-base (see: https://github.com/CenturyLinkLabs/panamax-ruby-base/commit/08ef298b842f4e48fd254b3c931977ae7f109993)

### Added
- Submit services to fleet in sorted order (#277)

0.2.13 - 2015-2-17
-------------------
### Added
- AWS Fleet job creation template (#276)

0.2.12 - 2015-2-10
-------------------
### Added
- Support for job creation via Dray (#261, #264, #265, #266, #267, #268, #270, #271, #272, #274, #275)

0.2.11 - 2014-12-17
-------------------
### Added
- Adding the ability to redeploy a remote deployment (#258)

0.2.10 - 2014-12-1
------------------
### Added
- Health check in metadata response (#252)
- Ability to pass an app id for deploying an app (#253)

### Changed
- Increased timeout for docker index search (#257, https://github.com/CenturyLinkLabs/panamax-ui/issues/424)

0.2.9 - 2014-11-21
------------------
### Changed
- Explicitely require fixtures in tests (#246)

0.2.8 - 2014-11-13
------------------
### Added 
- Ability to display Metadata for the agent and adapter (#248)

### Removed
- Active Resource dependency (#207)

0.2.7 - 2014-11-10
------------------
### Added 
- Support for new SCM service types (#227)
- Support for remote deployments

### Upgraded
- Rails to 4.1.7 (#240)


0.2.6 - 2014-10-21
------------------
### Fixed
- Ability to actually run an image from a private registry (#232)

0.2.5 - 2014-10-20
------------------
### Added

- Private Registry Support (#230, #229, #224, #223, #222, #219)
- Additional types (#225)


0.2.4 - 2014-10-10
------------------
### Added

- Ability to add, update, list, and delete private registries (#27)

### Fixed
- Github exceptions when saving a template (#216 & #218)


0.2.3 - 2014-02-02
------------------

### Added
- Return ports exposed by the Dockerfile in service details (#209)
- Support for mounting volumes from other containers using `--volumes-from` ([panamax-ui#283](https://github.com/CenturyLinkLabs/panamax-ui/issues/283))


0.2.2 - 2014-09-26
------------------

### Fixed
- -p flag bug in Docker run string (#208)

### Removed
- Panamax contest repo removed from TemplateRepo seeds (#210)


0.2.1 - 2014-09-18
------------------
### ADDED
- support for remote deployments (#205 and #207)

### Added
- Support for service renaming (#202)
- Better error messaging when trying to delete an in-use image (#203)

### Fixed
- Private repositories with port bug (#201)


0.2.0 - 2014-09-09
------------------

### Added
- Support for Fleet 0.6.0

### Removed
- Support for FLeet 0.5.0


0.1.3 - 2014-09-03
------------------

### Added
- Expose a rollup of all template keywords (#199)

### Fixed
- Allow setting the same host port numbers if protocol does not match (CenturyLinkLabs/panamax-ui#329)


0.1.2 - 2014-08-27
------------------

### Fixed
- Service command not copied from app to template (#187)
- Missing validation for exposed ports (centurylinklabs/panamax-ui#292)
- Not all GitHub repos shown when saving template (#194)
- Unexpected token error when running in CoreOS cluster (centurylinklabs/panamax-ui#296)
- Job state could not be achieved error (centurylinklabs/panamax-ui#297)
- ExecStop errors in service unit file generate journal noise


0.1.1 - 2014-08-11
------------------

### Added
- LICENSE
- robots.txt
- Virtual size now returned for `local_images#index`
- Limit parameter added to `local_images#index`, `repos#index` and `apps#index`
- Contest repo added as default template source
- Data sent to KissMetrics when any template is run or saved

### Deprecated
- Nothing

### Removed
- Nothing

### Fixed
- Better error message when trying to delete image that cannot be deleted
- Subscribe flag on users#update works as advertised


0.1.0 - 2014-08-04
------------------

Initial beta release
