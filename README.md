# Link16 JTIDS Research — C++ Project

> **English-first research mirror.** Original source: [shaohua0720/Link16_JTIDS](https://github.com/shaohua0720/Link16_JTIDS). Maintained here as a starting point for further research and development. Original MIT copyright and attribution remain in [LICENSE](LICENSE). The code is not verified as a working or standards-compliant Link 16 implementation.

## Project overview

This repository contains the upstream C++ project organized around message handling, coding and encryption, physical-layer abstractions, and simulation. The project uses CMake and targets C++17. Windows, Linux and macOS support is described upstream but has not been verified in this mirror.

## Features described by the upstream author

- **Message handling:** J-series message-type catalogue and message-word classes (header, initial, extension and continuation).
- **Coding:** Reed–Solomon, AES, parity/error detection and interleaving components.
- **Physical abstractions:** USRP interface classes, digital modulation, frequency management and synchronization.
- **Simulation:** AWGN and Rayleigh channel models, bit-error-rate and throughput metrics.

**Important:** The above is an inventory of claimed or named capabilities, not proof of a functioning end-to-end system.

## Source directory guide

| Path | Purpose |
| --- | --- |
| `src/api/` | API implementations: Link16, Message, Coding, Physical and Simulation |
| `src/application/` | Entry point, system coordinator, real-mode and simulation-mode applications |
| `src/core/` | Configuration, shared types, logging and utilities |
| `src/protocol/message/` | Message-word structures and message representation |
| `src/protocol/formats/` | J-series message catalogue |
| `src/protocol/interface/` | Protocol interface |
| `src/coding/error_correction/` | Error-correction code components |
| `src/coding/error_detection/` | Parity and CRC components |
| `src/coding/crypto/` | General-purpose cryptographic primitives |
| `src/coding/interleaving/` | Interleaver components |
| `src/physical/hardware/` | USRP and SDR abstractions |
| `src/physical/modulation/` | Modulator implementations |
| `src/physical/frequency/` | Frequency management abstractions |
| `src/physical/synchronization/` | Timing and frame synchronization abstractions |
| `src/simulation/` | Simulation engine, channel models and metrics |
| `include/link16/` | Public headers |
| `lib/schifra/` | Third-party Schifra headers |
| `tests/` | Test source and CTest setup |
| `docs/` | Documentation |
| `CMakeLists.txt` | Root build definition |
| `build.bat`, `build.sh` | Build helper scripts |
| `config.ini` | Configuration file |

Some folders described by the original author may be absent or placeholders. Use the actual Git tree as the source of truth.

## Getting started: offline source review

### Prerequisites

- Git
- CMake
- C++17 compiler: Visual Studio 2022, GCC or Clang

### Clone

```bash
git clone https://github.com/iNanisKa/Link16-JTIDS-Research.git
cd Link16-JTIDS-Research
```

### Windows — configure and compile

```powershell
cmake -S . -B build -G "Visual Studio 17 2022" -A x64
cmake --build build --config Debug
```

### Linux — configure and compile

```bash
cmake -S . -B build -DCMAKE_BUILD_TYPE=Debug
cmake --build build --verbose
```

**Build status:** not verified. Existing source-level inconsistencies may prevent compilation. Do not assume the resulting executable is functional or run any hardware/transmission code.

### Tests

If configuration and compilation succeed:

```bash
ctest --test-dir build --output-on-failure
```

Test coverage is limited; passing tests would not establish interoperability.

## Architecture overview

```text
Application / demo entry point
        |
    Public APIs
        |
 Message processing
        |
 Coding components
        |
 Physical abstractions
        |
 Simulation or device interface
```

The system coordinator `Link16System` selects a real-mode application or simulation application. The simulation-mode application's main run method contains an unfinished loop. The USRP discovery method inspected in the upstream source returns mock sample devices, not actual device discovery.

## Known engineering issues

1. `STDPMsg.h` and `STDPMsg.cpp` contain inconsistent names and method signatures.
2. Some includes referenced by `Link16App.cpp` do not match files found in the source tree.
3. `SimulationApp::run()` is unfinished.
4. At least one USRP device enumeration method is a stub.
5. The advertised functionality is not backed by comprehensive tests.

**Suggested first milestone:** perform a reproducible offline CMake build audit, log each compiler error, resolve general software inconsistencies in a separate branch, and add tests. This mirror is intended for research and code review, not live military-network or RF operation.

## Development notes

To extend a general-purpose module, create a feature branch, add unit tests and keep interfaces documented. Prefer standard C++17 and portable CMake target settings. Preserve all upstream attribution when modifying copied code.

## English-language documentation

- [Engineering overview and limitations](README_EN.md)
- [Upstream provenance](UPSTREAM_SOURCE.txt)
- [MIT license](LICENSE)

## Attribution and license

Original author/project: [shaohua0720/Link16_JTIDS](https://github.com/shaohua0720/Link16_JTIDS). This mirror retains the upstream MIT license and copyright notices. The repository owner maintains this copy but does not claim original authorship of upstream source code.
