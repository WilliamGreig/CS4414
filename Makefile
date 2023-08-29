# Compiler and compiler flags
CC = gcc
CFLAGS = -g

# Target executable name
TARGET = my_program

# Source file and object file
SRC = list_harness.c
OBJ = $(SRC:.c=.o)

# Include directory
INCLUDES = -I.

all: $(TARGET)

$(TARGET): $(OBJ)
	$(CC) $(CFLAGS) -o $(TARGET) $(OBJ)

%.o: %.c
	$(CC) $(CFLAGS) $(INCLUDES) -c $<

clean:
	rm -f $(OBJ) $(TARGET)