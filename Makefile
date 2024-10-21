TARGET = main
# Define the linker script location and chip architecture.
LD_SCRIPT = boot/linker.ld
MCU_SPEC  = cortex-m3

BUILD_DIR = ./bin/
# Toolchain definitions (ARM bare metal defaults)
TOOLCHAIN = /usr
CC = $(TOOLCHAIN)/bin/arm-none-eabi-gcc
AS = $(TOOLCHAIN)/bin/arm-none-eabi-as
LD = $(TOOLCHAIN)/bin/arm-none-eabi-ld
OC = $(TOOLCHAIN)/bin/arm-none-eabi-objcopy
OD = $(TOOLCHAIN)/bin/arm-none-eabi-objdump
OS = $(TOOLCHAIN)/bin/arm-none-eabi-size
# Assembly directives.
ASFLAGS += -c
ASFLAGS += -mcpu=$(MCU_SPEC)
ASFLAGS += -mthumb
ASFLAGS += -Wall

# C compilation directives
CFLAGS += -mcpu=$(MCU_SPEC)
CFLAGS += -mthumb
CFLAGS += -Wall
CFLAGS += -g
# (Set error messages to appear on a single line.)
CFLAGS += -fmessage-length=0
# (Set system to ignore semihosted junk)
CFLAGS += --specs=nosys.specs
# Linker directives.
LSCRIPT = ./$(LD_SCRIPT)
LFLAGS += -mcpu=$(MCU_SPEC)
LFLAGS += -mthumb
LFLAGS += -Wall
LFLAGS += --specs=nosys.specs
LFLAGS += -nostdlib
LFLAGS += -lgcc
LFLAGS += -T$(LSCRIPT)


AS_SRC   = ./boot/startup.s
AS_SRC   += ./boot/vectorTable.s

C_SRC    = ./core/src/main.c

INCLUDE  = -I./core/inc/
INCLUDE  += -I./drivers/cmsis/inc/

OBJS += $(patsubst %.c,$(BUILD_DIR)%.o,$(C_SRC))
OBJS += $(patsubst %.s,$(BUILD_DIR)%.o,$(AS_SRC))


all: $(BUILD_DIR)$(TARGET).bin

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)
	@echo -e "$(BOLD_YELLOW)This files will be created : $(BOLD_GREEN)$(OBJS)$(RESET)"

$(BUILD_DIR)%.o: %.s Makefile | $(BUILD_DIR)
	@mkdir -p $(dir $@) 
	@echo -e "$(BOLD_YELLOW)Compiling $(BOLD_GREEN)$<$(RESET)"
	$(CC) -x assembler-with-cpp $(ASFLAGS) $< -o $@

$(BUILD_DIR)%.o: %.c Makefile | $(BUILD_DIR)
	@mkdir -p $(dir $@) 
	@echo -e "$(BOLD_YELLOW)Compiling $(BOLD_GREEN)$<$(RESET)"
	$(CC) -c $(CFLAGS) $(INCLUDE) $< -o $@

$(BUILD_DIR)$(TARGET).elf: $(OBJS)
	$(CC) $^ $(LFLAGS) -o $@
$(BUILD_DIR)$(TARGET).bin: $(BUILD_DIR)$(TARGET).elf
	$(OC) -S -O binary $< $@
	$(OS) $<

.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)

.PHONY: flash
flash: $(BUILD_DIR)$(TARGET).elf
	openocd -f interface/stlink.cfg -f target/stm32f1x.cfg -c "program $(BUILD_DIR)$(TARGET).elf verify reset exit"

.PHONY: erase
erase:
	openocd -f interface/stlink.cfg -f target/stm32f1x.cfg -c "init; reset halt; flash erase_sector 0 0 0; reset run;shutdown"
