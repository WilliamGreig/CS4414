# Compiler and compiler flags
CC = gcc
CFLAGS = -g

# Target executable name
TARGET = test

# Source file and object file
SRC = main.c
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