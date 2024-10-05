# Snake Game on FPGA DE10-lite

## Description

This repository contains the implementation of the classic Snake game on the DE10-lite FPGA board. The project has been designed to provide a well-documented foundation, offering insights into the game's functionality and allowing others to replicate it on their own DE10-lite boards.

## Project Structure

- **Documentation.pdf**: Detailed documentation that explains the functionality of each component and provides instructions on how to replicate the game.
  
- **Guides Folder**:
  - **ADC with DE-series boards.pdf**: Guide on utilizing the FPGA's ADC (Analog-to-Digital Converter).
  - **Using the VGA.pdf**: Guide for creating a clock divider using Quartus Prime IPs for VGA display.
  - **DE10-lite User Manual.pdf**: User manual for the DE10-lite FPGA board used in the project.

- **Images Folder**: Contains the images used in the project.

- **Python_code Folder**:
  - **main.py**: Python script used to convert images into RGB matrices for use in the game.

- **snake_pin.csv**: CSV file listing all the pins used in the project. This file is essential for replicating the FPGA setup.

- **snake_game_video.mp4**: Demonstration video showcasing the various scenes and gameplay of the Snake game.

- **VHDL_codes Folder**: Contains the VHDL code modules referenced in the documentation:
  - **food.vhd**: VHDL module for generating the food for the Snake game.
  - **snake_entity.vhd**: Main VHDL module for the snake's logic and movement.
  - **hw_image_generator.vhd**: Image generator module for hardware-based image rendering.
  - **score.vhd**: Module handling the score display.
  - **joystick.vhd**: Module for interfacing with the joystick used in the game.
  - **vga_controller.vhd**: VGA controller module responsible for monitor configuration and display.
  - **utils Folder**:
    - **snake_pkg.vhd**: VHDL package containing constants and types used across the various modules.

## Requirements

- **Quartus Prime**: For synthesizing and deploying the VHDL code onto the DE10-lite FPGA.
- **Python 3.x**: For running the image conversion script (`main.py`).
- **DE10-lite FPGA Board**: The hardware platform for the project.
  
Feel free to explore the code and refer to the documentation for detailed instructions on how to set up and run the Snake game on your FPGA board.
