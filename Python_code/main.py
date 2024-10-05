from PIL import Image  # Importing the required module from the Python Imaging Library (PIL)
import numpy as np     # Importing NumPy for array manipulation capabilities

# Load the image
img = Image.open('./image.png').convert('RGBA')

# Resize the image to 31x31 pixels
img = img.resize((31, 31))

# Extract pixel data
pixel_data = np.array(img)

# Create the VHDL color array
vhdl_array = []
for row in pixel_data:
    vhdl_row = []
    for pixel in row:
        r, g, b, a = pixel
        # Use only fully opaque pixels (a == 255)
        if a == 255:
            vhdl_pixel = (r >> 4, g >> 4, b >> 4)  # Convert to 4-bit per color channel
        else:
            vhdl_pixel = (0, 0, 0)  # Black color for transparent pixels
        vhdl_row.append(vhdl_pixel)
    vhdl_array.append(vhdl_row)

# Generate VHDL code for the array
vhdl_code = "CONSTANT image : image_type := (\n"
for row in vhdl_array:
    vhdl_code += "  ("
    vhdl_code += ", ".join(f"X\"{r:01X}{g:01X}{b:01X}\"" for r, g, b in row)
    vhdl_code += "),\n"
vhdl_code = vhdl_code.rstrip(",\n") + "\n);"

# Save the VHDL code to a file
with open("./image.vhdl", "w") as f:
    f.write(vhdl_code)
