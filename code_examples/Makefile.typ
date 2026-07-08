```makefile
###############################################################################
# Makefile for TI-Jukebox Project
# Embedded Systems Class
#
# Project: TI-Jukebox
# Class:   Embedded Systems
# Author:  Felix Miller
# Contact: felix.miller@hm.edu
# Date:    2024-11
#
# Description:
# This Makefile is used for the TI-Jukebox to enable both a build on the host
# machine and for the target MCU.
# Note that this Makefile makes limited use of variables to increase readability
# and tries to avoid cryptic symbols on purpose.
#
# Usage:
# - make main   : Build for the host
# - make TARGET=mcu firmware.elf : Build the Firmware elf
# - make TARGET=mcu firmware.bin : Build the Firmware binary
# - make TARGET=mcu flash : Flash to the device
###############################################################################

ifeq ($(TARGET),mcu)
	CC = riscv64-unknown-elf-gcc
	CFLAGS = -DMCU_TARGET -DDISP_I2C --specs=picolibc.specs -std=c11 -Wall -Wextra -Wundef -Wshadow -pedantic -Wdouble-promotion -g -ffreestanding -fno-builtin-printf -fno-common -march=rv32imc -mabi=ilp32 -Os -ffunction-sections -fdata-sections 
else
    CC = gcc
	CFLAGS = -DHOST_TARGET -DDISP_I2C -std=c11 -Wall -Wextra -Wundef -Wshadow -pedantic -Wdouble-promotion -g
endif

# Define the port for flashing
PORT = /dev/ttyUSB0

# Default target
default: main

# Linking for host build
main: main.o playlist.o disp.o i2c_mock.o song_src.o system_mock.o
	$(CC)  main.o playlist.o disp.o i2c_mock.o song_src.o system_mock.o -o main

# Linking for device build using the esp32c3 linker script
firmware.elf: main.o playlist.o songs.o disp.o system.o
	$(CC) -T esp32c3.ld -nostdlib -nostartfiles -march=rv32imc -mabi=ilp32 -Wl,--gc-sections -Wl,-Map=firmware.map main.o playlist.o songs.o disp.o system.o -L. -li2c -o firmware.elf 

# Compile each .c file to an object file
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

# Compile assembly with song database (this mimics our "sdcard" for now)
songs.o: songs.S
	$(CC) $(CFLAGS) -c $< -o $@

# Create a binary from the ELF file
firmware.bin: firmware.elf
	esptool --chip esp32c3 elf2image --version 2 --dont-append-digest firmware.elf -o firmware.bin

# Flash the binary to the chip
flash: firmware.bin
	esptool --chip esp32c3 -p $(PORT) -b 460800 --before=default_reset --after=hard_reset write_flash --force --flash_mode dio --flash_freq 80m --flash_size 4MB 0x0 firmware.bin

# Unit Tests
jukebox_test.o: test/jukebox_test.c
	$(CC) $(CFLAGS) -I. -c test/jukebox_test.c -o jukebox_test.o

jukebox_test: jukebox_test.o disp.o i2c_mock.o
	$(CC)  jukebox_test.o disp.o i2c_mock.o -o jukebox_test -lcmocka

test: jukebox_test

# Clean up the build files
clean:
	rm -f *.o firmware.elf firmware.bin firmware.map main jukebox_test *.bmp

.PHONY: default clean flash test

```