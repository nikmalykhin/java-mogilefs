# Legacy Java 6 + Ant Build Environment (MogileFS)

## Overview

This project provides a Docker-based environment for compiling and running legacy Java 1.6 (Java 6) code using Apache Ant. It is designed to work with the original source code from the 2000s, without requiring any code changes or modernization.

## Prerequisites

- **x86_64 (Intel/AMD) host**: The Java 6 JDK used here is for x86_64 Linux. It will NOT run on Apple Silicon (ARM/M1/M2) Macs, even with Docker emulation.
- **Docker** installed on your system.
- The file `jdk-6u45-linux-x64.tar.gz` must be present in the project root (not included for licensing reasons).

## Quick Start

1. **Build the Docker Image**

   ```sh
   docker build -t mogilefs-legacy .
   ```

2. **Compile and Run the Safe Unit Test (URITest)**

   ```sh
   docker run --rm -v "$PWD":/app -w /app mogilefs-legacy bash -c "ant compile && java -cp classes com.guba.mogilefs.test.URITest"
   ```

   - This will compile the project and run only the `URITest` (which does not require any external infrastructure).
   - You should see output from the test and `BUILD SUCCESSFUL` from Ant.

## Notes

- **Integration tests** (e.g., `TestPut`, `TestMogileFS`) require a running MogileFS server and are NOT run by default.
- If you encounter errors about `/lib64/ld-linux-x86-64.so.2` or `qemu-x86_64`, you are likely on an ARM-based Mac. Please use an Intel/AMD machine or a compatible cloud VM.
- The Dockerfile uses Ubuntu 14.04, Java 6u45, and Ant 1.9.7 for maximum compatibility with legacy code.

## Troubleshooting

- Ensure `jdk-6u45-linux-x64.tar.gz` is in the project root before building.
- Only x86_64 hosts are supported for running this container.
- For further help, see the comments in the Dockerfile or contact your DevOps lead.

---

**Preserve the Era. Contain, Don't Modernize.**
