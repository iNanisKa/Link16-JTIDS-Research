# Link16_JTIDS — English engineering guide

This repository mirrors the publicly available C++ research project
[shaohua0720/Link16_JTIDS](https://github.com/shaohua0720/Link16_JTIDS).
**Original project copyright and MIT license are preserved.** This is
a research mirror, not an independently authored implementation and
not a certified or operational Link 16 system.

## Repository structure

- `src/application/` — entry point, system facade, application modes.
- `src/api/`, `include/link16/` — public API and wrappers.
- `src/protocol/` — message structures and format catalogue.
- `src/coding/` — general coding, parity, error correction, and cryptographic components.
- `src/physical/` — DSP and hardware-interface abstractions.
- `src/simulation/` — simulation classes and channel models.
- `tests/` — existing limited test harness.
- `CMakeLists.txt` — C++17 build configuration.

## Offline source inspection

Clone the repository, inspect the source and license, then optionally
configure the build without running radio hardware:

```bash
git clone https://github.com/iNanisKa/Link16-JTIDS-Research.git
cd Link16-JTIDS-Research
cmake -S . -B build-review -DCMAKE_BUILD_TYPE=Debug
```

The upstream README lists `build.bat` and `build.sh`, but a successful
build has **not** been verified. Record any compiler errors before modifying
source. Do not assume compatibility with official Link 16 standards.

## Known gaps identified by source inspection

- `SimulationApp::run()` contains an unfinished main simulation loop.
- `USRPInterface::getAvailableDevices()` returns mocked sample devices.
- `STDPMsg.h` and `STDPMsg.cpp` contain inconsistent member names/signatures.
- Some `Link16App.cpp` include paths do not match the observed source tree.
- The existing automated test coverage is limited.

## Engineering handoff

1. Record the upstream commit SHA and full file inventory.
2. Verify source provenance and third-party library licenses.
3. Run an offline CMake configure and capture exact diagnostics.
4. Classify each subsystem as implemented, partial, stub, or unverified.
5. Create isolated unit tests for generic software components.
6. Keep hardware disconnected; do not transmit or claim operational interoperability.

## Attribution

Original source: https://github.com/shaohua0720/Link16_JTIDS

License: see [LICENSE](LICENSE), MIT, Copyright (c) 2023 Link16 Project.

English guide and research mirror maintenance are separate from upstream authorship.
