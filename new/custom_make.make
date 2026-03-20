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
LDSCRIPT = STM32F401XX_FLASH.ld

# Include paths
INCLUDES = -I$(INC_DIR) \
           -I$(CUBE_DIR)/Drivers/CMSIS/Device/ST/STM32F4xx/Include \
           -I$(CUBE_DIR)/Drivers/CMSIS/Include \
           -I$(CUBE_DIR)/Drivers/STM32F4xx_HAL_Driver/Inc -I$(CUBE_DIR)/Drivers/STM32F4xx_HAL_Driver/Inc/Legacy

# Compiler flags
CFLAGS = $(CPU) $(FPU) $(FLOAT-ABI) -mthumb -Wall -g -Og \
         -D$(MCU_MODEL) -DUSE_HAL_DRIVER $(INCLUDES)
CFLAGS += -ffunction-sections -fdata-sections


# Linker flags
LDFLAGS = $(CPU) -mthumb $(FPU) $(FLOAT-ABI) \
          -specs=nano.specs -T$(LDSCRIPT) \
          -Wl,-Map=$(BUILD_DIR)/$(PROJECT).map,--cref \
          -Wl,--gc-sections -lc -lm -lnosys

# Tools
CC = arm-none-eabi-gcc
AS = arm-none-eabi-gcc
LD = arm-none-eabi-ld
OBJCOPY = arm-none-eabi-objcopy
SIZE = arm-none-eabi-size

# Replace your OBJECTS lines with these:
OBJECTS = $(addprefix $(BUILD_DIR)/,$(notdir $(SRC:.c=.o)))
OBJECTS += $(addprefix $(BUILD_DIR)/,$(notdir $(ASM:.s=.o)))

# Add vpath so Make can find sources by filename alone
vpath %.c $(sort $(dir $(SRC)))
vpath %.s $(sort $(dir $(ASM)))

# Targets
.PHONY: all clean flash

all: $(BUILD_DIR) $(BUILD_DIR)/$(PROJECT).elf $(BUILD_DIR)/$(PROJECT).hex $(BUILD_DIR)/$(PROJECT).bin

$(BUILD_DIR):
	mkdir -p $@

$(BUILD_DIR)/%.o: %.c | $(BUILD_DIR)
	$(CC) -c $(CFLAGS) $< -o $@

$(BUILD_DIR)/%.o: %.s | $(BUILD_DIR)
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
