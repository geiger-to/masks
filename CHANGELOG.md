# Changelog

## [0.4.0](https://github.com/geiger-to/masks/compare/masks/v0.3.2...masks/v0.4.0) (2024-04-11)


### Features

* add a basic ux for viewing devices ([c30b494](https://github.com/geiger-to/masks/commit/c30b49453a91c624d9e1f52d5ccb64d2f83d5c24))
* auto-assign the first redirect_uri during authorization ([d5a9e4c](https://github.com/geiger-to/masks/commit/d5a9e4c13c28a3575c8f36221506a42d87dc89e3))
* create actors from management ux ([4725d7c](https://github.com/geiger-to/masks/commit/4725d7c7721e39de2fc4605357f3b401ff781bfb))
* create and delete clients in the management ux ([aaae21e](https://github.com/geiger-to/masks/commit/aaae21ecbc8e21f3aabc798e0ef237afd1cc6557))
* manage clients in the masks management ui ([ddc34ff](https://github.com/geiger-to/masks/commit/ddc34ff84e27647fa0ce546f48ca0c54e6580cf0))
* store a `return_to` value for protected resources. ([90ffda9](https://github.com/geiger-to/masks/commit/90ffda9c3e73493f1c0340f821a1afd8928064c0))
* support openid connect protocol ([a6759ea](https://github.com/geiger-to/masks/commit/a6759ea1023e0ebad325bae7c6c618f5f63908c7))
* toggle password visibility ([3b1a0bd](https://github.com/geiger-to/masks/commit/3b1a0bdca0a1676badf32c8094ad327c4e258c91))


### Bug Fixes

* properly validate access is allowed on masks ([3ca5a12](https://github.com/geiger-to/masks/commit/3ca5a12a788a8abf095eeb89b8f170c555711eeb))
* protect /manage et al from actors without masks:manage scope ([e3a6c84](https://github.com/geiger-to/masks/commit/e3a6c84f048bb649111e2304a6fc2358289813de))

## [0.3.2](https://github.com/geiger-to/masks/compare/masks/v0.3.1...masks/v0.3.2) (2024-03-29)


### Bug Fixes

* add rules to allow rake masks:assign_scopes ([44d10e5](https://github.com/geiger-to/masks/commit/44d10e5731276012aaa3276be3a76a1ed694563f))
* redirect to /session on failed manager access ([5151a25](https://github.com/geiger-to/masks/commit/5151a25c87c769ab1451943be491058acc4ca947))

## [0.3.1](https://github.com/geiger-to/masks/compare/masks/v0.3.0...masks/v0.3.1) (2024-03-29)


### Bug Fixes

* include the version number in docs ([476db85](https://github.com/geiger-to/masks/commit/476db85c36793027bf10bdd26cba54780e4d1acf))

## [0.3.0](https://github.com/geiger-to/masks/compare/masks/v0.2.0...masks/v0.3.0) (2024-03-29)


### Features

* automate releasing new versions of masks ([a96b83f](https://github.com/geiger-to/masks/commit/a96b83f033a923def63549047cc10e6d53136c60))


### Miscellaneous Chores

* release 0.1.2 ([a6a9613](https://github.com/geiger-to/masks/commit/a6a9613e996fe85688d798afbe9a269bf4c9b659))
* release 0.3.0 ([b0eb71d](https://github.com/geiger-to/masks/commit/b0eb71d4237b0959134b39875797967ac481a07d))

## [0.1.2](https://github.com/geiger-to/masks/compare/masks/v0.1.1...masks/v0.1.2) (2024-02-20)


### Miscellaneous Chores

* release 0.1.2 ([a6a9613](https://github.com/geiger-to/masks/commit/a6a9613e996fe85688d798afbe9a269bf4c9b659))

## [0.1.1](https://github.com/geiger-to/masks/compare/masks-v0.1.0...masks/v0.1.1) (2024-02-20)


### Features

* automate releasing new versions of masks ([a96b83f](https://github.com/geiger-to/masks/commit/a96b83f033a923def63549047cc10e6d53136c60))
