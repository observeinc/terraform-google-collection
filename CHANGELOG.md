## [0.5.1](https://github.com/observeinc/terraform-google-collection/compare/v0.5.0...v0.5.1) (2025-05-19)


### Bug Fixes

* bump function max memory default ([#50](https://github.com/observeinc/terraform-google-collection/issues/50)) ([2875cd0](https://github.com/observeinc/terraform-google-collection/commit/2875cd0fb5429e1e6f937ab696e0f0e396358298))
* updating to point at the latest version ([#53](https://github.com/observeinc/terraform-google-collection/issues/53)) ([0f3c5ae](https://github.com/observeinc/terraform-google-collection/commit/0f3c5ae7b6ff82e722e9c60ccf823d5ac4c3420b))



# [0.5.0](https://github.com/observeinc/terraform-google-collection/compare/v0.6.0...v0.5.0) (2023-08-29)



# [0.6.0](https://github.com/observeinc/terraform-google-collection/compare/v0.4.0...v0.6.0) (2023-08-29)


### Bug Fixes

* bump max memory for functions ([#48](https://github.com/observeinc/terraform-google-collection/issues/48)) ([a3fcf3b](https://github.com/observeinc/terraform-google-collection/commit/a3fcf3b962790493f4891d3ddee82b73138477da))
* **limit:** fix character limits ([#49](https://github.com/observeinc/terraform-google-collection/issues/49)) ([625234f](https://github.com/observeinc/terraform-google-collection/commit/625234fa71747ab976407af3a4baad783b1ff5f7))


### Features

* add sample TF to create service accounts ([#47](https://github.com/observeinc/terraform-google-collection/issues/47)) ([c1c36fb](https://github.com/observeinc/terraform-google-collection/commit/c1c36fb30c486643f29734f1fe50d619258bbd20))



# [0.4.0](https://github.com/observeinc/terraform-google-collection/compare/v0.3.0...v0.4.0) (2023-08-15)


### Bug Fixes

* add project id to bucket name to make unique ([#39](https://github.com/observeinc/terraform-google-collection/issues/39)) ([f93191d](https://github.com/observeinc/terraform-google-collection/commit/f93191d4644b0b3fc559ada0e48c9d31511f7044))
* allow folder sinks to include children projects when collecting ([#26](https://github.com/observeinc/terraform-google-collection/issues/26)) ([43ec51f](https://github.com/observeinc/terraform-google-collection/commit/43ec51f1b2b57824b5104e35ce6f55efe9b62db5))
* bump max instances from 5 to 100 as a default ([#42](https://github.com/observeinc/terraform-google-collection/issues/42)) ([0490bce](https://github.com/observeinc/terraform-google-collection/commit/0490bce13cf4b80b9328f9b7a49cc0b11359f7f9))
* change function default memory to 512mb ([#25](https://github.com/observeinc/terraform-google-collection/issues/25)) ([c96efdc](https://github.com/observeinc/terraform-google-collection/commit/c96efdcce71b55ed334590fd27ba8c4631f1eb47))
* remove deprecated collection code ([#30](https://github.com/observeinc/terraform-google-collection/issues/30)) ([86b5cdb](https://github.com/observeinc/terraform-google-collection/commit/86b5cdb427374fb9ebe27b636e98508804007d45))
* **task-queue:** use a task queue and check on the long-running task ([#44](https://github.com/observeinc/terraform-google-collection/issues/44)) ([a8cf96e](https://github.com/observeinc/terraform-google-collection/commit/a8cf96e043308e7c245a03ea11e63d32ac1814e6))
* update cloudscheduler service account name ([#45](https://github.com/observeinc/terraform-google-collection/issues/45)) ([414d620](https://github.com/observeinc/terraform-google-collection/commit/414d6202baf7aaadffe8c6a8b3aee192f487b94d))


### Features

* add asset feed ([#37](https://github.com/observeinc/terraform-google-collection/issues/37)) ([c548580](https://github.com/observeinc/terraform-google-collection/commit/c548580fba0557ede79f5847006ce40937b2250b))
* add third function to collect assets not captured in asset export or feed ([#41](https://github.com/observeinc/terraform-google-collection/issues/41)) ([44f507a](https://github.com/observeinc/terraform-google-collection/commit/44f507a65efea5bbfc10d24a800827cc7a3cf021))
* **asset-api:** use the new Google cloud function that exercises the asset inventory api ([#32](https://github.com/observeinc/terraform-google-collection/issues/32)) ([f3d9340](https://github.com/observeinc/terraform-google-collection/commit/f3d934022b7b8b1fcf2134f97e275eab1e1eda11))


### Reverts

* Revert "add asset.tf an an auto.tfvars to folder example" ([518624b](https://github.com/observeinc/terraform-google-collection/commit/518624b32cd05e58707c0100296cdcf86ebc0c89))



# [0.3.0](https://github.com/observeinc/terraform-google-collection/compare/v0.2.0...v0.3.0) (2023-01-12)


### Features

* set function_max_instances default to 5 ([#22](https://github.com/observeinc/terraform-google-collection/issues/22)) ([90a8d45](https://github.com/observeinc/terraform-google-collection/commit/90a8d45888a60eeba593f94915ea68eb4e440891))
* support orgs and folders ([#21](https://github.com/observeinc/terraform-google-collection/issues/21)) ([ff068c5](https://github.com/observeinc/terraform-google-collection/commit/ff068c51089eb2ef3cd2cf0fcbfc2f02b8f3ebb6))
* use cloud function v0.2.0 ([#23](https://github.com/observeinc/terraform-google-collection/issues/23)) ([3797f47](https://github.com/observeinc/terraform-google-collection/commit/3797f4786b172a51db50af6f3acc97fc98548dbe))



# [0.2.0](https://github.com/observeinc/terraform-google-collection/compare/v0.1.2...v0.2.0) (2022-11-21)


### Bug Fixes

* pass name format ([#18](https://github.com/observeinc/terraform-google-collection/issues/18)) ([18444d9](https://github.com/observeinc/terraform-google-collection/commit/18444d995264ae9a6de529b118b609935739803f))


### Features

* add collection extension approach ([#17](https://github.com/observeinc/terraform-google-collection/issues/17)) ([04b20c2](https://github.com/observeinc/terraform-google-collection/commit/04b20c26ff8e744deeb571e2650d844a3b7e4027))



## [0.1.2](https://github.com/observeinc/terraform-google-collection/compare/v0.1.1...v0.1.2) (2022-09-21)


### Bug Fixes

* update read me and examples ([#16](https://github.com/observeinc/terraform-google-collection/issues/16)) ([3660b4c](https://github.com/observeinc/terraform-google-collection/commit/3660b4cfa313d821ebce6c1fa8c50945ab0e6364))



## [0.1.1](https://github.com/observeinc/terraform-google-collection/compare/v0.1.0...v0.1.1) (2022-09-15)


### Bug Fixes

* update readme and add output ([#13](https://github.com/observeinc/terraform-google-collection/issues/13)) ([2c67d86](https://github.com/observeinc/terraform-google-collection/commit/2c67d8629c6c1b67f4a9d8bff5964c27e58de6e6))



# [0.1.0](https://github.com/observeinc/terraform-google-collection/compare/db4d5960be8d1d54cf0dc1e17d78f6fae599c9f3...v0.1.0) (2022-09-08)


### Features

* first release ([db4d596](https://github.com/observeinc/terraform-google-collection/commit/db4d5960be8d1d54cf0dc1e17d78f6fae599c9f3))



