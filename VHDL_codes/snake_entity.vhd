LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
USE ieee.std_logic_arith.all;
USE work.snake_pkg.ALL;

ENTITY snake_entity IS
	PORT(
		clock 			: IN STD_LOGIC;
		reset 			: IN STD_LOGIC;
		food_x 			: IN INTEGER;
		food_y 			: IN INTEGER;
		direction  		: IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		snake_out      : OUT snake_array;
		snake_len_out  : OUT INTEGER;
		gameOver_out   : OUT BOOLEAN;
		lives_out      : OUT INTEGER
	);
END snake_entity;

ARCHITECTURE behavior OF snake_entity IS
		
	-- Internal signals
	SIGNAL internal_snake : snake_array := (
		OTHERS => (x => game_left + (rect_width*10)+((rect_width+1) / 2), y => game_top + (rect_width*10)+((rect_height+1) / 2))
	);	-- Initial position of the snake's head
	SIGNAL snake_length : INTEGER := 1; -- Initial snake length
	SIGNAL current_direction : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";  -- Initial direction: 00 = Up
	SIGNAL game_over : BOOLEAN;
	SIGNAL lives : INTEGER := 3; -- Initial number of lives
  
BEGIN
	-- Process for handling snake movement and game logic
	snake_logic: PROCESS(clock, reset)
		VARIABLE i : INTEGER;
	BEGIN
		IF reset = '1' THEN
			internal_snake(0).x <= game_left + (rect_width*10) + ((rect_width+1) / 2);
			internal_snake(0).y <= game_top + (rect_width*10) + ((rect_height+1) / 2);
			snake_length <= 1;
			current_direction <= "00"; 
			lives <= 3;
			game_over <= FALSE;
    
		ELSIF rising_edge(clock) AND snake_length < max_snake_length AND game_over = FALSE THEN
	 
			-- Update direction based on joystick commands
			IF direction = "10" THEN
				CASE current_direction IS
					WHEN "00" => current_direction <= "10";  -- Up -> Left
					WHEN "10" => current_direction <= "10";  -- Left -> Left
					WHEN "11" => current_direction <= "10";  -- Down -> Left
					WHEN "01" => current_direction <= "01";  -- Right -> Right
					WHEN OTHERS => NULL;
				END CASE;
			ELSIF direction = "01" THEN
				CASE current_direction IS
					WHEN "00" => current_direction <= "01";  -- Up -> Right
					WHEN "01" => current_direction <= "01";  -- Right -> Right
					WHEN "11" => current_direction <= "01";  -- Down -> Right
					WHEN "10" => current_direction <= "10";  -- Left -> Left
					WHEN OTHERS => NULL;
				END CASE;
			ELSIF direction = "00" THEN
				CASE current_direction IS
					WHEN "00" => current_direction <= "00";  -- Up -> Up
					WHEN "01" => current_direction <= "00";  -- Right -> Up
					WHEN "11" => current_direction <= "11";  -- Down -> Down
					WHEN "10" => current_direction <= "00";  -- Left -> Up
					WHEN OTHERS => NULL;
				END CASE;
			ELSIF direction = "11" THEN
				CASE current_direction IS
					WHEN "00" => current_direction <= "00";  -- Up -> Up
					WHEN "01" => current_direction <= "11";  -- Right -> Down
					WHEN "11" => current_direction <= "11";  -- Down -> Down
					WHEN "10" => current_direction <= "11";  -- Left -> Down
					WHEN OTHERS => NULL;
				END CASE;
			END IF;

			-- Move the snake
			FOR i IN max_snake_length - 1 DOWNTO 1 LOOP
				IF i < snake_length THEN
					internal_snake(i) <= internal_snake(i - 1);
				END IF;
			END LOOP;

			-- Use current_direction to move the snake
			CASE current_direction IS
				WHEN "00" => IF internal_snake(0).y - rect_height > game_top THEN internal_snake(0).y <= internal_snake(0).y - rect_height; END IF;  -- Su
				WHEN "10" => IF internal_snake(0).x - rect_width > game_left THEN internal_snake(0).x <= internal_snake(0).x - rect_width; END IF;   -- Sinistra
				WHEN "11" => IF internal_snake(0).y + rect_height < game_bottom THEN internal_snake(0).y <= internal_snake(0).y + rect_height; END IF;-- Giù
				WHEN "01" => IF internal_snake(0).x + rect_width < game_right THEN internal_snake(0).x <= internal_snake(0).x + rect_width; END IF;   -- Destra
				WHEN OTHERS => NULL;
			END CASE;

			-- Check for collisions with the snake itself
			FOR i IN 1 TO max_snake_length - 1 LOOP
				IF i < snake_length AND internal_snake(0).x = internal_snake(i).x AND internal_snake(0).y = internal_snake(i).y THEN
					IF lives = 1 THEN
						game_over <= TRUE;
						lives <= lives - 1;
						snake_length <= 1;  -- Reset game
					ELSE
						lives <= lives - 1;
						snake_length <= 1;  -- Reset game
					END IF;
				END IF;
			END LOOP;

			-- Check if the snake has eaten the food
			IF internal_snake(0).x = food_x AND internal_snake(0).y = food_y THEN					
				internal_snake(snake_length).x <= internal_snake(snake_length - 1).x;
				internal_snake(snake_length).y <= internal_snake(snake_length - 1).y;
				snake_length <= snake_length + 1; 
			END IF;
			
		END IF;
	END PROCESS snake_logic;
	
	-- Output assignments
	gameOver_out <= game_over;
	lives_out <= lives;
	snake_len_out <= snake_length;
	snake_out <= internal_snake;
			
END behavior;