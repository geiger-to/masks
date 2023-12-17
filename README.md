# masks

an over-engineered framework for access verification.

# `masks.json`

masks is configured with a `masks.json` file or equivalent data structure.
the json data should contain two top-level keys:

- `masks`: a list of `mask`s your app uses
- `types`: a hash of `type`s any `mask` may reference

whenever `masks` is invoked it searches for a `mask` to apply for the given
context. a mask's `type` dictates _how_ and _when_ the mask is applied, if
at all.
