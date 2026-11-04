# Link16 Link-Level Simulation — MATLAB Research Copy

> English documentation for the public MATLAB research project originally created by [shaohua0720](https://github.com/shaohua0720/Link16_LinkLevel_Sim). This is an **unverified offline experiment**, not a certified or operational Link 16 implementation.

## Project overview

The MATLAB source explores digital communication simulations and performance measurement: modulation/demodulation, error-correction coding, matrix interleaving, simplified CCSK spreading, a frequency-hopping experimental path and bit-error-rate (BER) plots.

## File guide

| File | Description |
| --- | --- |
| `Link16.m` | Main simulation experiment and BER performance chart |
| `CCSKModulator.m`, `CCSKDemodulator.m` | Simplified spreading and despreading routines |
| `FHmodulator.m`, `FHdemodulator.m` | Frequency-hopping signal simulation helpers |
| `MSKmodulator.m`, `MSKdemodulator.m` | Custom MSK simulation routines |
| `MSK_test.m` | BER and waveform tests |
| `MSK_debug.m` | Debug plots and correlation visualizations |
| `RSEncoder.m`, `RSDecoder.m` | Reed–Solomon coding experiments |

## Upstream feature list

The original author describes BPSK, QPSK, 16QAM, 64QAM, MSK, hopping, RS(31,15), convolutional coding, interleaving, CCSK, CRC, and BER analysis. These are descriptions of source-code paths, **not independently verified operational capabilities**.

## Reading the project

1. Open `Link16.m` in MATLAB Editor.
2. Review the inline settings `ENABLE_FH`, `MODULATION_TYPE`, `ENABLE_CRC`, `CODING_TYPE`, `ENABLE_INTERLEAVING`, and `ENABLE_CCSK`.
3. Inspect the processing modules and test scripts; MATLAB and additional toolboxes may be required.

**Execution status:** No MATLAB run or numerical validation has been performed for this mirror. The English translation is limited to documentation, comments and human-facing text.

## Source inconsistencies

- The Chinese README lists `LSY_CCSKde32.m` and `LSY_RSCode.m`, but those files are not in the archived repository.
- Some parameter descriptions in the original README differ from numeric settings in the code.
- The original SNR-sweep comment does not match the actual `snrValues` expression; the English review preserves the source expression.

## Provenance and rights

Original repository: https://github.com/shaohua0720/Link16_LinkLevel_Sim

Archived upstream Git tree: `67ac9a7e710e94713b8717a5eaa55fcd0410e618`.

The upstream tree contains **no LICENSE file**. A publicly accessible GitHub repository is not necessarily licensed for redistribution or derivative work. Keep the original attribution and obtain copyright-holder permission before distributing modified copies. The MIT license elsewhere in this parent repository does **not** automatically apply to these MATLAB files.

See [SOURCE_AND_LICENSE.md](SOURCE_AND_LICENSE.md).
