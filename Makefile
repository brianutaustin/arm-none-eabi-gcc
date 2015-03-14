#
#	███████╗   ███████╗   ██████╗
#	██╔════╝   ██╔════╝   ██╔══██╗
#	█████╗     ███████╗   ██████╔╝
#	██╔══╝     ╚════██║   ██╔═══╝
#	███████╗██╗███████║██╗██║
#	╚══════╝╚═╝╚══════╝╚═╝╚═╝
#
#    Makefile for ARM TIVA LAUNCHPAD
#    Author: Anderson Ignacio da Silva
#    Date: 04/07/2014
#    Target:PART_TM4C123GH6PM
#    Inf.: http://www.esplatforms.blogspot.com.br
#	 
#	 This makefile was based on Mauro Scomparin Makefile for Stellaris <http://scompoprojects.worpress.com>
#    

# Prefix for the arm-eabi-none toolchain.
COMPILER = arm-none-eabi

# Microcontroller properties.
PART=TM4C123GH6PM
CPU=-mcpu=cortex-m4
FPU=-mfpu=fpv4-sp-d16 -mfloat-abi=softfp

# Tivaware path
TIVAWARE_PATH=/home/brianasus/tilib/

# Program name definition for ARM GNU C compiler.
CC      = ${COMPILER}-gcc
# Program name definition for ARM GNU Linker.
LD      = ${COMPILER}-ld
# Program name definition for ARM GNU Object copy.
CP      = ${COMPILER}-objcopy
# Program name definition for ARM GNU Object dump.
OD      = ${COMPILER}-objdump
# Program name definition for ARM GNU Debugger.
DB		= ${COMPILER}-gdb

# Aditional flags to the compiler
CFLAGS=-mthumb ${CPU} ${FPU} -O3 -ffunction-sections -fdata-sections -MD -std=c99 -Wall -pedantic -c -g
# Library paths passed as flags.
CFLAGS+= -I ${TIVAWARE_PATH} -DPART_$(PART) -c -DTARGET_IS_BLIZZARD_RA1

# Flags for linker
LFLAGS  = --gc-sections

# Flags for objcopy
CPFLAGS = -Obinary

# Flags for objectdump
ODFLAGS = -S

# Obtain the path to libgcc, libc.a and libm.a for linking from gcc frontend.
LIB_GCC_PATH=${shell ${CC} ${CFLAGS} -print-libgcc-file-name}
LIBC_PATH=${shell ${CC} ${CFLAGS} -print-file-name=libc.a}
LIBM_PATH=${shell ${CC} ${CFLAGS} -print-file-name=libm.a}

# Uploader tool path.
FLASHER=lm4flash

# Flags for the uploader program.
FLASHER_FLAGS=

# Terminal
TERMINAL=xfce4-terminal
# On chip debugger 
OC_DEBUGGER=openocd
# Config file absolute path
CONFIG_PATH=/usr/share/openocd/scripts/boards/ek-tm4c123gxl.cfg    


#==============================================================================
#                         Project properties
#==============================================================================

# Project name (name of main file)
PROJECT_NAME = main
# Startup file name
STARTUP_FILE = startup_gcc
# Linker file name
LINKER_FILE = ldStart.ld

SRC = $(wildcard *.c)
OBJS = $(SRC:.c=.o)

#==============================================================================
#                      Rules to make the target
#==============================================================================

#make all rule
all: $(OBJS) ${PROJECT_NAME}.axf ${PROJECT_NAME}

%.o: %.c
	@echo
	@echo Compiling $<...
	$(CC) -c $(CFLAGS) ${<} -o ${@}

${PROJECT_NAME}.axf: $(OBJS)
	@echo
	@echo Making driverlib
	$(MAKE) -C ${TIVAWARE_PATH}driverlib/
	@echo
	@echo Linking...
	$(LD) -T $(LINKER_FILE) $(LFLAGS) -o ${PROJECT_NAME}.axf $(OBJS) ${TIVAWARE_PATH}driverlib/gcc/libdriver.a $(LIBM_PATH) $(LIBC_PATH) $(LIB_GCC_PATH)

${PROJECT_NAME}: ${PROJECT_NAME}.axf
	@echo
	@echo Copying...
	$(CP) $(CPFLAGS) ${PROJECT_NAME}.axf ${PROJECT_NAME}.bin
	@echo
	@echo Creating list file...
	$(OD) $(ODFLAGS) ${PROJECT_NAME}.axf > ${PROJECT_NAME}.lst

# make clean rule
clean:
	@echo Cleaning $<...
	rm *.bin *.o *.d *.axf *.lst

# Rule to load the project to the board (sudo may be needed if rule is note made).
flash:
	@echo Loading the ${PROJECT_NAME}.bin
	${FLASHER} ${PROJECT_NAME}.bin ${FLASHER_FLAGS}

#   GDB:
#	target extended-remote :3333
#	monitor reset halt
#	load
#	monitor reset init

debug:
	@echo -e 'gdb commands:\n   target extended-remote :3333\n   monitor reset halt\n   load\n   monitor reset init\n'
	${TERMINAL} -x ${DB} ${PROJECT_NAME}.axf
	${OC_DEBUGGER} -f ${CONFIG_PATH}
	
test:
	@echo -e 'gdb commands:\n   target extended-remote :3333\n   monitor reset halt\n   load\n   monitor reset init\n'

