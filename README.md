# Custom CI/CD Pipeline for STM32

A custom CI/CD pipeline that brings modern DevOps practices to embedded firmware development on the STM32F401 microcontroller. The pipeline automates static analysis and board flashing on every push, with unit testing via Ceedling coming next.

Inspired by and built with reference to the [Artful Bytes](https://www.youtube.com/@ArtfulBytes) video series on CI/CD for embedded systems.

---

## Features

- **Static Analysis** using [Cppcheck](http://cppcheck.net/) — runs automatically on every push to catch bugs before they reach hardware
- **Automated Firmware Flashing** using OpenOCD — builds the `.elf` and flashes it directly to the STM32 board
- **Dockerized Toolchain** — uses a custom Docker image (`rithvidas/stm32f401-toolchain`) to ensure a consistent build environment across all runs
- **GitHub Actions** based workflow triggered on push to `main` and `develop`, and on pull requests to `main`

---

## Pipeline Overview

```
Push / PR
    |
    v
Static Analysis (Cppcheck)
    |
    v
Build Firmware (arm-none-eabi-gcc)
    |
    v
Flash Board (OpenOCD)
```

### Job 1: Static Analysis

Runs `cppcheck` against `Core/Src/main.c` with all STM32 HAL and CMSIS include paths. The report is uploaded as a GitHub Actions artifact even if errors are found, so you can always inspect the output.

### Job 2: Flash (Coming Soon in CI)

OpenOCD is configured via `openocd.cfg` to connect to the STM32F401 over ST-Link and flash the compiled binary.

---

## Project Structure

```
.
├── .github/workflows/       # GitHub Actions workflow files
├── Core/                    # Application source and headers
│   ├── Inc/
│   └── Src/
├── Cube_Directory/Drivers/  # STM32 HAL and CMSIS drivers
├── build/                   # Compiled output
├── startup/                 # Startup assembly files
├── ci.yml                   # CI/CD pipeline definition
├── dockerfile               # Custom Docker image definition
├── openocd.cfg              # OpenOCD flash configuration
├── STM32Make.make           # Main Makefile
├── custom_make.make         # Custom make rules
├── STM32F401XX_FLASH.ld     # Linker script
└── STM32F401.svd            # SVD file for peripheral debugging
```

---

## Getting Started

### Prerequisites

- Docker (for running the pipeline locally)
- `arm-none-eabi-gcc` toolchain
- `cppcheck`
- OpenOCD
- STM32F401 board with ST-Link

### Run Static Analysis Locally

```bash
cppcheck \
  --enable=all \
  --error-exitcode=1 \
  --suppress=missingIncludeSystem \
  -DSTM32F401xC -DUSE_HAL_DRIVER \
  -I Core/Inc \
  -I Cube_Directory/Drivers/STM32F4xx_HAL_Driver/Inc \
  -I Cube_Directory/Drivers/CMSIS/Device/ST/STM32F4xx/Include \
  -I Cube_Directory/Drivers/CMSIS/Include \
  Core/Src/main.c
```

### Build Firmware

```bash
make -f STM32Make.make
```

### Flash the Board

```bash
openocd -f openocd.cfg -c "program build/your_firmware.elf verify reset exit"
```

---

## Docker Image

The pipeline uses a custom Docker image that bundles the full ARM toolchain and required tools. The image is hosted on Docker Hub:

```
rithvidas/stm32f401-toolchain:latest
```

---

## Roadmap

- [x] Static analysis with Cppcheck
- [x] Automated board flashing with OpenOCD
- [ ] Unit testing with [Ceedling](http://www.throwtheswitch.org/ceedling)
- [ ] Mock function testing
- [ ] Code coverage reporting

---

## Reference

- [Artful Bytes](https://www.youtube.com/@ArtfulBytes) - CI/CD for Embedded Systems video series
- [Cppcheck Documentation](http://cppcheck.net/)
- [OpenOCD Documentation](https://openocd.org/doc/html/index.html)
- [Ceedling](http://www.throwtheswitch.org/ceedling)

---

## Target Hardware

| Parameter | Value |
|-----------|-------|
| MCU | STM32F401 |
| Architecture | ARM Cortex-M4 |
| Toolchain | arm-none-eabi-gcc |
| Debugger/Flasher | ST-Link via OpenOCD |
