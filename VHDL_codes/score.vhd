-- Import IEEE standard libraries
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
USE ieee.std_logic_arith.all;

-- Entity declaration for the score display
ENTITY score IS
	PORT(
		display_r	: OUT STD_LOGIC_VECTOR (6 downto 0);
		display_l   : OUT STD_LOGIC_VECTOR (6 downto 0);
		display_c	: OUT STD_LOGIC_VECTOR (6 downto 0);
		display_f   : OUT STD_LOGIC_VECTOR (6 downto 0);
		display_u   : OUT STD_LOGIC_VECTOR (6 downto 0);
		display_d   : OUT STD_LOGIC_VECTOR (6 downto 0);
		point   		: IN INTEGER
	);
END score;

-- Architecture definition for the score entity
ARCHITECTURE behavior OF score IS

   -- Type declaration for the seven-segment display codes
	TYPE segments_type IS ARRAY (0 TO 13) OF STD_LOGIC_VECTOR(6 DOWNTO 0);

	-- Constant array holding the seven-segment display codes for digits 0-9, 'C', 'F', 'U', and '-'
	CONSTANT segments : segments_type := (
		"1000000", -- 0
      "1111001", -- 1
      "0100100", -- 2
      "0110000", -- 3
      "0011001", -- 4
      "0010010", -- 5
      "0000010", -- 6
      "1111000", -- 7
      "0000000", -- 8
      "0010000", -- 9
		"1000110", -- C
		"0001110", -- F
		"1000001", -- U
		"0111111" -- dash
	);
	
	-- Function to get the display code for a given value
	FUNCTION get_display_code(value : INTEGER) RETURN STD_LOGIC_VECTOR IS
		BEGIN
			IF value >= 0 AND value <= 9 THEN
				RETURN segments(value);
			ELSE
            RETURN "1111111"; -- Display blank
			END IF;
   END get_display_code;
	
BEGIN
   -- Process to update the right and left display segments based on the score (point)
	display : PROCESS(point)
	BEGIN
		IF point >= 0 AND point <= 32 THEN
			display_r <= get_display_code((point-1) MOD 10);
         display_l <= get_display_code((point-1) / 10);
		ELSE
         display_r <= "1111111";
         display_l <= "1111111"; -- Display blank or error
      END IF;
   END PROCESS display;
	-- Constantly display 'C', 'F', 'U', and '-'
	display_c <= segments(10);
	display_f <= segments(11);
	display_u <= segments(12);
	display_d <= segments(13);
END behavior;