LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;
USE work.snake_pkg.ALL;

ENTITY food IS
	PORT(
		clock          : IN STD_LOGIC;
		reset 			: IN STD_LOGIC;
		food_x 			: OUT INTEGER;
		food_y 			: OUT INTEGER;
		snake_in  		: IN snake_array
	);
END food;

ARCHITECTURE behavior OF food IS

	-- Internal signals
	SIGNAL food_x_internal : INTEGER := game_left + (rect_width*10) + ((rect_width+1) / 2);
	SIGNAL food_y_internal : INTEGER := game_top + (rect_width*10) + ((rect_height+1) / 2);
	
	SIGNAL lfsr : STD_LOGIC_VECTOR(15 DOWNTO 0) := X"ACE1"; -- Initial value of the Linear Feedback Shift Register (LFSR)

	-- Function to generate random numbers using the LFSR
	FUNCTION random_number(min_val, max_val : INTEGER; lfsr_val : STD_LOGIC_VECTOR(15 DOWNTO 0)) RETURN INTEGER IS
		VARIABLE lfsr_temp : STD_LOGIC_VECTOR(15 DOWNTO 0);
		VARIABLE random_val : INTEGER;
	BEGIN
		lfsr_temp := lfsr_val;
    
		-- Perform one iteration of the LFSR
		lfsr_temp := lfsr_temp(14 DOWNTO 0) & (lfsr_temp(15) XOR lfsr_temp(13) XOR lfsr_temp(12) XOR lfsr_temp(10));
    
		-- Convert the LFSR value to an integer
		random_val := to_integer(unsigned(lfsr_temp));
    
		-- Limit the value within the specified range
		RETURN (random_val MOD (max_val - min_val + 1)) + min_val;
	END FUNCTION;
  
BEGIN

	-- Game logic process
	food_logic: PROCESS(reset, clock)
		VARIABLE new_food_col, new_food_row : INTEGER;
	BEGIN
		IF reset = '1' THEN
			-- Reset the food position to the initial coordinates
			food_x_internal <= game_left + (rect_width*10) + ((rect_width+1) / 2);
			food_y_internal <= game_top + (rect_width*10) + ((rect_height+1) / 2);
    
		ELSIF rising_edge(clock) THEN
			-- Update the LFSR
			lfsr <= lfsr(14 DOWNTO 0) & (lfsr(15) XOR lfsr(13) XOR lfsr(12) XOR lfsr(10));

			-- Check if the snake has eaten the food
			IF snake_in(0).x = food_x_internal AND snake_in(0).y = food_y_internal THEN
				-- Reposition the food to a new random location
				new_food_row := random_number(0, 19, lfsr);
				new_food_col := random_number(0, 29, lfsr);
				food_x_internal <= game_left + new_food_col * rect_width + ((rect_width+1) / 2);
				food_y_internal <= game_top + new_food_row * rect_height + ((rect_height+1) / 2);
			END IF;
		END IF;
	END PROCESS food_logic;
	
	-- Output assignments
	food_x <= food_x_internal;
	food_y <= food_y_internal;
			
END behavior;