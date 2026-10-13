
## Support

Abseil follows Google's [Foundational C++ Support
Policy](https://opensource.google/documentation/policies/cplusplus-support). See
[this
table](https://github.com/google/oss-policies-info/blob/main/foundational-cxx-support-matrix.md)
for a list of currently supported versions compilers, platforms, and build
tools.

<a name="codemap"></a>
## Codemap

Abseil contains the following C++ library components:

* [`base`](absl/base/)
  <br /> The `base` library contains initialization code and other code which
  all other Abseil code depends on. Code within `base` may not depend on any
  other code (other than the C++ standard library).
* [`algorithm`](absl/algorithm/)
  <br /> The `algorithm` library contains additions to the C++ `<algorithm>`
  library and container-based versions of such algorithms.
* [`cleanup`](absl/cleanup/)
  <br /> The `cleanup` library contains the control-flow-construct-like type
  `absl::Cleanup` which is used for executing a callback on scope exit.
* [`container`](absl/container/)
  <br /> The `container` library contains additional STL-style containers,
  including Abseil's unordered "Swiss table" containers.
* [`crc`](absl/crc/) The `crc` library contains code for
  computing error-detecting cyclic redundancy checks on data.
* [`debugging`](absl/debugging/)
  <br /> The `debugging` library contains code useful for enabling leak
  checks, and stacktrace and symbolization utilities.
* [`flags`](absl/flags/)
  <br /> The `flags` library contains code for handling command line flags for
  libraries and binaries built with Abseil.
* [`hash`](absl/hash/)
  <br /> The `hash` library contains the hashing framework and default hash
  functor implementations for hashable types in Abseil.
* [`log`](absl/log/)
  <br /> The `log` library contains `LOG` and `CHECK` macros and facilities
  for writing logged messages out to disk, `stderr`, or user-extensible
  destinations.
* [`memory`](absl/memory/)
  <br /> The `memory` library contains memory management facilities that augment
  C++'s `<memory>` library.
* [`meta`](absl/meta/)
  <br /> The `meta` library contains type checks
  similar to those available in the C++ `<type_traits>` library.
* [`numeric`](absl/numeric/)
  <br /> The `numeric` library contains 128-bit integer types as well as
  implementations of C++20's bitwise math functions.
* [`profiling`](absl/profiling/)
  <br /> The `profiling` library contains utility code for profiling C++
  entities.  It is currently a private dependency of other Abseil libraries.
* [`random`](absl/random/)
  <br /> The `random` library contains functions for generating pseudorandom
  values.
* [`status`](absl/status/)
  <br /> The `status` library contains abstractions for error handling,
  specifically `absl::Status` and `absl::StatusOr<T>`.
* [`strings`](absl/strings/)
  <br /> The `strings` library contains a variety of strings routines and
  utilities.
* [`synchronization`](absl/synchronization/)
  <br /> The `synchronization` library contains concurrency primitives (Abseil's
  `absl::Mutex` class, an alternative to `std::mutex`) and a variety of
  synchronization abstractions.
* [`time`](absl/time/)
  <br /> The `time` library contains abstractions for computing with absolute
  points in time, durations of time, and formatting and parsing time within
  time zones.
* [`types`](absl/types/)
  <br /> The `types` library contains non-container utility types.
* [`utility`](absl/utility/)
  <br /> The `utility` library contains utility and helper code.

<a name="releases"></a>
## Releases

Abseil recommends users "live-at-head" (update to the latest commit from the
master branch as often as possible). However, we realize this philosophy doesn't
work for every project, so we also provide [Long Term Support
Releases](https://github.com/abseil/abseil-cpp/releases) to which we backport
fixes for severe bugs. See our [release
management](https://abseil.io/about/releases) document for more details.

<a name="license"></a>
## License

The Abseil C++ library is licensed under the terms of the Apache
license. See [LICENSE](LICENSE) for more information.

<a name="links"></a>
## Links

For more information about Abseil:

* Consult our [Abseil Introduction](https://abseil.io/about/intro)
* Read [Why Adopt Abseil](https://abseil.io/about/philosophy) to understand our
  design philosophy.
* Peruse our
  [Abseil Compatibility Guarantees](https://abseil.io/about/compatibility) to
  understand both what we promise to you, and what we expect of you in return.
