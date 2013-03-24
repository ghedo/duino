package App::duino::Command::build;

use strict;
use warnings;

use App::duino -command;

use Text::Template;
use File::Basename;
use File::Path qw(make_path);

=head1 NAME

App::duino::Command::build - Build an Arduino sketch

=head1 SYNOPSIS

  $ duino build --board uno

=cut

sub abstract { 'build an Arduino sketch' }

sub usage_desc { '%c build %o' }

sub execute {
	my ($self, $opt, $args) = @_;

	my $board_name    = $opt -> board;
	my $makefile_name = ".build/$board_name/Makefile";

	unless (-e $makefile_name) {
		make_path(dirname $makefile_name);

		open my $makefile, '>', $makefile_name
			or die "Can't create Makefile.\n";

		my $template = Text::Template -> new(
			TYPE => 'FILEHANDLE', SOURCE => \*DATA
		);

		my $makefile_opts = {
			board   => $board_name,
			variant => $self -> config($opt, 'build.variant'),
			mcu     => $self -> config($opt, 'build.mcu'),
			f_cpu   => $self -> config($opt, 'build.f_cpu'),
			vid     => $self -> config($opt, 'build.vid'),
			pid     => $self -> config($opt, 'build.pid'),
			arduino_libs => $opt -> libs,
			arduino_dir => $opt -> dir,
			arduino_sketchbook => $opt -> sketchbook,
		};

		$template -> fill_in(
			OUTPUT => $makefile, HASH => $makefile_opts
		);
	}

	system 'make', '--silent', '-f', $makefile_name;
}

=head1 AUTHOR

Alessandro Ghedini <alexbio@cpan.org>

=head1 LICENSE AND COPYRIGHT

Copyright 2013 Alessandro Ghedini.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut

1; # End of App::duino::Command::build

__DATA__
# Arduino command line tools Makefile
# System part (i.e. project independent)
#
# Copyright (C) 2010,2011,2012 Martin Oldfield <m@mjo.tc>, based on
# work that is copyright Nicholas Zambetti, David A. Mellis & Hernando
# Barragan.
# 
# This file is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as
# published by the Free Software Foundation; either version 2.1 of the
# License, or (at your option) any later version.
#
# Adapted from Arduino 0011 Makefile by Alessandro Ghedini

BOARD_TAG = {$board}

VARIANT   = {$variant}
MCU       = {$mcu}
F_CPU     = {$f_cpu}
USB_VID   = {$vid}
USB_PID   = {$pid}

ARDUINO_DIR        = {$arduino_dir}
ARDUINO_LIBS       = {$arduino_libs}
ARDUINO_VERSION    = 100
ARDUINO_SKETCHBOOK = {$arduino_sketchbook}

ARDUINO_LIB_PATH  = $(ARDUINO_DIR)/libraries
ARDUINO_CORE_PATH = $(ARDUINO_DIR)/hardware/arduino/cores/arduino
ARDUINO_VAR_PATH  = $(ARDUINO_DIR)/hardware/arduino/variants

USER_LIB_PATH = $(ARDUINO_SKETCHBOOK)/libraries

AVR_TOOLS_DIR     = $(ARDUINO_DIR)/hardware/tools/avr
AVRDUDE_CONF      = $(AVR_TOOLS_DIR)/etc/avrdude.conf
AVR_TOOLS_PATH    = $(AVR_TOOLS_DIR)/bin

OBJDIR  = .build/$(BOARD_TAG)

LOCAL_C_SRCS    = $(wildcard *.c)
LOCAL_CPP_SRCS  = $(wildcard *.cpp)
LOCAL_CC_SRCS   = $(wildcard *.cc)
LOCAL_PDE_SRCS  = $(wildcard *.pde)
LOCAL_INO_SRCS  = $(wildcard *.ino)
LOCAL_AS_SRCS   = $(wildcard *.S)
LOCAL_OBJ_FILES = $(LOCAL_C_SRCS:.c=.o)   $(LOCAL_CPP_SRCS:.cpp=.o) \
		$(LOCAL_CC_SRCS:.cc=.o)   $(LOCAL_PDE_SRCS:.pde=.o) \
		$(LOCAL_INO_SRCS:.ino=.o) $(LOCAL_AS_SRCS:.S=.o)
LOCAL_OBJS      = $(patsubst %,$(OBJDIR)/%,$(LOCAL_OBJ_FILES))

# core sources
CORE_C_SRCS     = $(wildcard $(ARDUINO_CORE_PATH)/*.c)
CORE_CPP_SRCS   = $(wildcard $(ARDUINO_CORE_PATH)/*.cpp)

ifneq ($(strip $(NO_CORE_MAIN_CPP)),)
CORE_CPP_SRCS := $(filter-out %main.cpp, $(CORE_CPP_SRCS))
endif

CORE_OBJ_FILES  = $(CORE_C_SRCS:.c=.o) $(CORE_CPP_SRCS:.cpp=.o)
CORE_OBJS       = $(patsubst $(ARDUINO_CORE_PATH)/%,  \
			$(OBJDIR)/%,$(CORE_OBJ_FILES))

########################################################################
# Rules for making stuff
#

TARGET     = $(notdir $(CURDIR))

# The name of the main targets
TARGET_HEX = $(OBJDIR)/$(TARGET).hex
TARGET_ELF = $(OBJDIR)/$(TARGET).elf
TARGETS    = $(OBJDIR)/$(TARGET).*
CORE_LIB   = $(OBJDIR)/libcore.a

# Names of executables
CC      = $(AVR_TOOLS_PATH)/avr-gcc
CXX     = $(AVR_TOOLS_PATH)/avr-g++
OBJCOPY = $(AVR_TOOLS_PATH)/avr-objcopy
OBJDUMP = $(AVR_TOOLS_PATH)/avr-objdump
AR      = $(AVR_TOOLS_PATH)/avr-ar
SIZE    = $(AVR_TOOLS_PATH)/avr-size
NM      = $(AVR_TOOLS_PATH)/avr-nm
MV      = mv -f
CAT     = cat
ECHO    = echo

# General arguments
SYS_LIBS      = $(patsubst %,$(ARDUINO_LIB_PATH)/%,$(ARDUINO_LIBS))
USER_LIBS     = $(patsubst %,$(USER_LIB_PATH)/%,$(ARDUINO_LIBS))
SYS_INCLUDES  = $(patsubst %,-I%,$(SYS_LIBS))
USER_INCLUDES = $(patsubst %,-I%,$(USER_LIBS))
LIB_C_SRCS    = $(wildcard $(patsubst %,%/*.c,$(SYS_LIBS)))
LIB_CPP_SRCS  = $(wildcard $(patsubst %,%/*.cpp,$(SYS_LIBS)))
USER_LIB_CPP_SRCS   = $(wildcard $(patsubst %,%/*.cpp,$(USER_LIBS)))
USER_LIB_C_SRCS     = $(wildcard $(patsubst %,%/*.c,$(USER_LIBS)))
LIB_OBJS      = $(patsubst $(ARDUINO_LIB_PATH)/%.c,$(OBJDIR)/%.o,$(LIB_C_SRCS)) \
		$(patsubst $(ARDUINO_LIB_PATH)/%.cpp,$(OBJDIR)/%.o,$(LIB_CPP_SRCS))
USER_LIB_OBJS = $(patsubst $(USER_LIB_PATH)/%.cpp,$(OBJDIR)/%.o,$(USER_LIB_CPP_SRCS)) \
		$(patsubst $(USER_LIB_PATH)/%.c,$(OBJDIR)/%.o,$(USER_LIB_C_SRCS))

CPPFLAGS      = -mmcu=$(MCU) -DF_CPU=$(F_CPU) -DARDUINO=$(ARDUINO_VERSION) \
			-I. -I$(ARDUINO_CORE_PATH) -I$(ARDUINO_VAR_PATH)/$(VARIANT) \
			$(SYS_INCLUDES) $(USER_INCLUDES) -g -Os -w -Wall \
			-DUSB_VID=$(USB_VID) -DUSB_PID=$(USB_PID) \
			-ffunction-sections -fdata-sections

CFLAGS        = -std=gnu99
CXXFLAGS      = -fno-exceptions
ASFLAGS       = -mmcu=$(MCU) -I. -x assembler-with-cpp
LDFLAGS       = -mmcu=$(MCU) -Wl,--gc-sections -Os

# library sources
$(OBJDIR)/%.o: $(ARDUINO_LIB_PATH)/%.c
	$(ECHO) 'Building $(shell basename $<)'
	mkdir -p $(dir $@)
	$(CC) -c $(CPPFLAGS) $(CFLAGS) $< -o $@

$(OBJDIR)/%.o: $(ARDUINO_LIB_PATH)/%.cpp
	$(ECHO) 'Building $(shell basename $<)'
	mkdir -p $(dir $@)
	$(CC) -c $(CPPFLAGS) $(CXXFLAGS) $< -o $@

$(OBJDIR)/%.o: $(USER_LIB_PATH)/%.cpp
	$(ECHO) 'Building $(shell basename $<)'
	mkdir -p $(dir $@)
	$(CC) -c $(CPPFLAGS) $(CFLAGS) $< -o $@

$(OBJDIR)/%.o: $(USER_LIB_PATH)/%.c
	$(ECHO) 'Building $(shell basename $<)'
	mkdir -p $(dir $@)
	$(CC) -c $(CPPFLAGS) $(CFLAGS) $< -o $@

# normal local sources
# .o rules are for objects, .d for dependency tracking
# there seems to be an awful lot of duplication here!!!
$(OBJDIR)/%.o: %.c
	$(ECHO) 'Building $(shell basename $<)'
	$(CC) -c $(CPPFLAGS) $(CFLAGS) $< -o $@

$(OBJDIR)/%.o: %.cc
	$(ECHO) 'Building $(shell basename $<)'
	$(CXX) -c $(CPPFLAGS) $(CXXFLAGS) $< -o $@

$(OBJDIR)/%.o: %.cpp
	$(ECHO) 'Building $(shell basename $<)'
	$(CXX) -c $(CPPFLAGS) $(CXXFLAGS) $< -o $@

# the pde -> cpp -> o file
$(OBJDIR)/%.cpp: %.pde
	$(ECHO) 'Building $(shell basename $<)'
	$(ECHO) '#include "WProgram.h"' > $@
	$(CAT)  $< >> $@

# the ino -> cpp -> o file
$(OBJDIR)/%.cpp: %.ino
	$(ECHO) 'Building $(shell basename $<)'
	$(ECHO) '#include <Arduino.h>' > $@
	$(CAT)  $< >> $@

$(OBJDIR)/%.o: $(OBJDIR)/%.cpp
	$(CXX) -c $(CPPFLAGS) $(CXXFLAGS) $< -o $@

# core files
$(OBJDIR)/%.o: $(ARDUINO_CORE_PATH)/%.c
	$(ECHO) 'Building $(shell basename $<)'
	$(CC) -c $(CPPFLAGS) $(CFLAGS) $< -o $@

$(OBJDIR)/%.o: $(ARDUINO_CORE_PATH)/%.cpp
	$(ECHO) 'Building $(shell basename $<)'
	$(CXX) -c $(CPPFLAGS) $(CXXFLAGS) $< -o $@

# various object conversions
$(OBJDIR)/%.hex: $(OBJDIR)/%.elf
	$(ECHO) 'Building $(shell basename $<)'
	$(OBJCOPY) -O ihex -R .eeprom $< $@

all: 		$(OBJDIR) $(TARGET_HEX)

$(OBJDIR):
		mkdir $(OBJDIR)

$(TARGET_ELF): 	$(LOCAL_OBJS) $(CORE_LIB) $(OTHER_OBJS)
		$(CC) $(LDFLAGS) -o $@ $(LOCAL_OBJS) $(CORE_LIB) $(OTHER_OBJS) -lc -lm

$(CORE_LIB):	$(CORE_OBJS) $(LIB_OBJS) $(USER_LIB_OBJS)
		$(AR) rcs $@ $(CORE_OBJS) $(LIB_OBJS) $(USER_LIB_OBJS)

.PHONY: all
