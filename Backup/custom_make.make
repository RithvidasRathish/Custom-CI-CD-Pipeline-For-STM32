# Project name
PROJECT = Test_HAL_Blink

# MCU details
MCU_FAMILY = STM32F4xx
MCU_MODEL = STM32F401xC
CPU = -mcpu=cortex-m4
FPU = -mfpu=fpv4-sp-d16
FLOAT-ABI = -mfloat-abi=hard

# Paths
BUILD_DIR = build
SRC_DIR = Core/Src
INC_DIR = Core/Inc
STARTUP_DIR = startup
CUBE_DIR = Cube_Directory

# Source files
HAL_SRC = $(wildcard $(CUBE_DIR)/Drivers/STM32F4xx_HAL_Driver/Src/*.c)

SRC = $(wildcard $(SRC_DIR)/*.c) $(HAL_SRC)
ASM = $(wildcard $(STARTUP_DIR)/*.s)
ls = $(wildcard *.ld)

# Include paths
INCLUDES = -I$(INC_DIR) \
           -I$(CUBE_DIR)/Drivers/CMSIS/Device/ST/STM32F4xx/Include \
           -I$(CUBE_DIR)/Drivers/CMSIS/Include \
           -I$(CUBE_DIR)/Drivers/STM32F4xx_HAL_Driver/Inc -I$(CUBE_DIR)/Drivers/STM32F4xx_HAL_Driver/Inc/Legacy

# Compiler flags
CFLAGS = $(CPU) $(FPU) $(FLOAT-ABI) -mthumb -Wall -g -Og \
         -D$(MCU_MODEL) -DUSE_HAL_DRIVER \
         $(INCLUDES)
CFLAGS += -ffunction-sections -fdata-sections


# Linker flags
LDFLAGS = -T $(ls) -Wl,-Map=$(BUILD_DIR)/$(PROJECT).map \
          --specs=nano.specs -lc -lm -lnosys
LDFLAGS += -Wl,--gc-sections

# Tools
CC = arm-none-eabi-gcc
AS = arm-none-eabi-gcc
LD = arm-none-eabi-ld
OBJCOPY = arm-none-eabi-objcopy
SIZE = arm-none-eabi-size

# Object files
OBJECTS = $(patsubst %.c,$(BUILD_DIR)/%.o,$(SRC))
OBJECTS += $(patsubst %.s,$(BUILD_DIR)/%.o,$(ASM))

# Targets
.PHONY: all clean flash

all: $(BUILD_DIR) $(BUILD_DIR)/$(PROJECT).elf $(BUILD_DIR)/$(PROJECT).hex $(BUILD_DIR)/$(PROJECT).bin

$(BUILD_DIR):
	mkdir -p $@

$(BUILD_DIR)/%.o: %.c
	mkdir -p $(dir $@)
	$(CC) -c $(CFLAGS) $< -o $@

$(BUILD_DIR)/%.o: %.s
	mkdir -p $(dir $@)
	$(AS) -c $(CFLAGS) $< -o $@

$(BUILD_DIR)/$(PROJECT).elf: $(OBJECTS)
	$(CC) $(OBJECTS) $(CFLAGS) $(LDFLAGS) -o $@
	$(SIZE) $@

$(BUILD_DIR)/$(PROJECT).hex: $(BUILD_DIR)/$(PROJECT).elf
	$(OBJCOPY) -O ihex $< $@

$(BUILD_DIR)/$(PROJECT).bin: $(BUILD_DIR)/$(PROJECT).elf
	$(OBJCOPY) -O binary $< $@

flash:
	st-flash write $(BUILD_DIR)/$(PROJECT).bin 0x8000000
	
openocd_flash:
	openocd -f ./openocd.cfg -c "program $(BUILD_DIR)/$(PROJECT).elf verify reset exit"


clean:
	rm -rf $(BUILD_DIR)
