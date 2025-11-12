[![License: CERN-OHL-W-2.0](https://img.shields.io/badge/License-CERN--OHL--W--2.0-blue.svg)](LICENSE)
[![FPGA](https://img.shields.io/badge/FPGA-Verilog--2001-green.svg)]()
[![Status](https://img.shields.io/badge/status-active-success.svg)]()

---

# photone-synth
FPGA-based MIDI synthesizer for ambient tone generation with dual-voice polyphony and basic reverb processing (part of the Photone vision-controlled FPGA synthesizer system).

---

> ⚙️ **Note:**
> MIDI uses a current-loop interface and cannot be connected directly to FPGA pins.
> You must use an **optocoupler (6N138)** or a **MIDI-to-UART shield/module** for signal isolation.
> Additionally, a **TTL 3.3 V ↔ 5 V level shifter** is required between the MIDI interface and the FPGA.
>
> Make sure to verify the **sampling rate configuration** of the **AN831 (WM8731)** module when using the provided driver.

---

## Module Hierarchy

```text
top.v
├── top_midi.v
│   ├── midi_rx.v
│   └── midi_parser.v
│
├── top_synth.v
│   ├── midi_to_freq.v
│   ├── midi_to_freq.v   (2 instances)
│   ├── osc.v
│   │   └── sine_rom.v
│   ├── osc.v
│   │   └── sine_rom.v
│   └── mixer.v
│
├── reverb.v
│   ├── delayline.xci
│   ├── delayline.xci
│   ├── delayline.xci
│   └── delayline.xci
│
└── top_codec.v
    ├── rst_delay.v
    ├── reg_config.v
    ├── i2c_com.v
    └── audio_out.v
```

---

## Data Flow

```text
MIDI In 
        ↓
     top_midi
        ↓
     top_synth
        ↓
 Oscillators → Mixer → Reverb
        ↓
     top_codec (WM8731)
        ↓
  I²C Configuration → I²S Output
        ↓
     Audio Out (Line / Headphone)
```

---

## Notes / Disclaimer

* This project is structured for **maximum reusability**.
  Modules such as `midi_parser`, `midi_to_freq`, and `osc` are self-contained and can be easily integrated into other FPGA audio projects.

* The **MIDI interface** must comply with electrical standards; direct connection to FPGA UART pins without isolation or level shifting will **damage hardware**.

* The **reverb** module uses **delayline IP cores** (Xilinx).
  You may adjust tap depth and feedback parameters inside `reverb.v` for different effects.

* The **WM8731 codec driver** is derived from **Alinx’s AN831 original example**.
  It runs reliably, though the internal structure can be somewhat cluttered.
  For a more advanced configuration approach, refer to [prism-analyzer](https://github.com/RefrXn/prism-analyzer).

* The **current reverb version** is for **testing purposes only**.
  A more advanced **convolution reverb** is being developed in [conv-reverb-lab](https://github.com/RefrXn/conv-reverb-lab).

* **Hardware used:**

  * **FPGA Board:** ALINX ZYNQ7020B
  * **Codec Module:** Alinx AN831 (WM8731)
  * **MIDI Interface:** 6N138 or MIDI-UART Shield
  * **Power/Logic Level:** 3.3 V↔5 V TTL Converter

---

## License

**CERN Open Hardware Licence Version 2 - Strongly Reciprocal (CERN-OHL-S-2.0)**

Copyright © 2025 RefrXn

This source describes Open Hardware and is licensed under the CERN-OHL-S v2.

You may redistribute and modify this documentation and design files under the terms of the CERN-OHL-S v2.
A copy of the license is included in this repository in the file `LICENSE`, and may also be obtained at:
[https://ohwr.org/cern_ohl_s_v2.txt](https://ohwr.org/cern_ohl_s_v2.txt)

You are granted the right to:

* Use, copy, modify, and distribute this design and documentation;
* Manufacture products using the licensed material;
* Convey modified or derivative works under the same license terms.

You must:

* Retain the copyright notice, license reference, and disclaimers in all copies;
* Provide access to the modified source when you distribute or sell products based on it;
* Clearly indicate the modifications you made and the date of modification.

This license comes **without any warranty**, to the extent permitted by applicable law.
See the full text of the license for detailed terms and conditions.

---

本项目为 **南京邮电大学「电子之声」活动参赛作品**  
**SPDX-License-Identifier:** CERN-OHL-S-2.0

