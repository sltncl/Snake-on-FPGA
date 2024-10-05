-- Import IEEE standard libraries
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
USE ieee.std_logic_arith.all;

-- Import custom package for the snake game
USE work.snake_pkg.ALL;

ENTITY hw_image_generator IS
	PORT(
		clock       : IN  STD_LOGIC;      -- Clock signal
      clock_ADC   : IN  STD_LOGIC;      -- ADC clock signal
      reset       : IN  STD_LOGIC;      -- Reset signal
      disp_ena    : IN  STD_LOGIC;      -- Display enable ('1' = display time, '0' = blanking time)
      row         : IN  INTEGER;        -- Pixel row coordinate
      column      : IN  INTEGER;        -- Pixel column coordinate
      red         : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');  -- Red color output
      green       : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');  -- Green color output
      blue        : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');  -- Blue color output
      display_r   : OUT STD_LOGIC_VECTOR (6 downto 0);  
      display_l   : OUT STD_LOGIC_VECTOR (6 downto 0);  
      display_c   : OUT STD_LOGIC_VECTOR (6 downto 0);  
      display_f   : OUT STD_LOGIC_VECTOR (6 downto 0);  
      display_u   : OUT STD_LOGIC_VECTOR (6 downto 0);  
      display_d   : OUT STD_LOGIC_VECTOR (6 downto 0)   
	);
END hw_image_generator;

-- Architecture definition for the hw_image_generator entity
ARCHITECTURE behavior OF hw_image_generator IS

	-- Internal signals for clock divider process
	SIGNAL clk_out_signal	: STD_LOGIC := '0';
	SIGNAL count 				: STD_LOGIC_VECTOR (21 downto 0) := (OTHERS => '0');
	
	-- Internal signals for components 
	SIGNAL snake_length 		: INTEGER;
	SIGNAL lives 				: INTEGER;
	SIGNAL internal_snake 	: snake_array;
	SIGNAL food_x 				: INTEGER;
	SIGNAL food_y 				: INTEGER;
	SIGNAL game_over 			: BOOLEAN;  
	SIGNAL direction  		: STD_LOGIC_VECTOR(1 DOWNTO 0);
	
	-- Snake entity component declaration
	COMPONENT snake_entity
		PORT (
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
	END COMPONENT;
	
	-- Food entity component declaration
	COMPONENT food
		PORT (
			clock				: IN STD_LOGIC;
			reset 			: IN STD_LOGIC;
			food_x 			: OUT INTEGER;
			food_y 			: OUT INTEGER;
			snake_in  		: IN snake_array
		);
	END COMPONENT;
	
	-- Score entity component declaration
	COMPONENT score
		PORT (
			display_r	: OUT STD_LOGIC_VECTOR (6 downto 0);
			display_l   : OUT STD_LOGIC_VECTOR (6 downto 0);
			display_c	: OUT STD_LOGIC_VECTOR (6 downto 0);
			display_f   : OUT STD_LOGIC_VECTOR (6 downto 0);
			display_u   : OUT STD_LOGIC_VECTOR (6 downto 0);
			display_d   : OUT STD_LOGIC_VECTOR (6 downto 0);
			point   		: IN INTEGER
		);
	END COMPONENT;
	
	-- Joystick entity component declaration
	COMPONENT joystick
		PORT (
			clock 		: IN STD_LOGIC;
			reset			: IN STD_LOGIC;
			direction 	: OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
		);
	END COMPONENT;
	
	
BEGIN
	
	 -- Instantiate snake entity
	S1 : snake_entity PORT MAP (
		clock 			=> clk_out_signal,
		reset 			=> reset,
		food_x 			=> food_x,
		food_y 			=> food_y,
		direction 		=> direction,
		snake_out 		=> internal_snake,
		snake_len_out 	=> snake_length,
		gameOver_out 	=> game_over,
		lives_out 		=> lives
	);
	
	-- Instantiate food entity
	S2 : food PORT MAP (
		clock 	=> clk_out_signal,
		reset 	=> reset,
		food_x 	=> food_x,
		food_y 	=> food_y,
		snake_in => internal_snake
	);
	
	-- Instantiate score entity
	S3 : score PORT MAP (
		display_r 	=> display_r,
		display_l 	=> display_l,
		display_c 	=> display_c,
		display_f 	=> display_f,
		display_u 	=> display_u,
		display_d 	=> display_d,
		point 		=> snake_length
	);
	
	-- Instantiate joystick entity
	S4 : joystick PORT MAP (
		clock 		=> clock_ADC,
		reset 		=> reset,
		direction 	=> direction
	);
  
	-- Clock divider process
	my_clockDivider: PROCESS(clock)
	BEGIN
		IF rising_edge(clock) THEN
			IF count = "1001100010010110011111" THEN 
				clk_out_signal <= not clk_out_signal;
				count <= (OTHERS => '0');
			ELSE 
				count <= count + '1';
			END IF;
		END IF;
	END PROCESS my_clockDivider;

	-- Display logic process
	display_logic: PROCESS(disp_ena, row, column) 
		VARIABLE i 					: INTEGER;
		VARIABLE snake_row 		: INTEGER;
		VARIABLE snake_col 		: INTEGER;
		VARIABLE food_row 		: INTEGER;
		VARIABLE food_col 		: INTEGER;
		VARIABLE gameOver_row 	: INTEGER;
		VARIABLE gameOver_col 	: INTEGER;
		VARIABLE live_row 		: INTEGER;
		VARIABLE live_col 		: INTEGER;
		VARIABLE victory_row 	: INTEGER;
		VARIABLE victory_col 	: INTEGER;
	BEGIN
		IF disp_ena = '1' THEN   -- Display time
			red <= (OTHERS => '0');
			green <= (OTHERS => '0');
			blue <= (OTHERS => '0');

			IF game_over = FALSE THEN
		
				IF snake_length = max_snake_length THEN
               
					-- Draw victory screen
					IF column >= game_left + (game_width/2) - 156 AND column < game_left + (game_width/2) + 156 AND
						row >= game_top + (game_height/2) - 20 AND row < game_top + (game_height/2) + 20 THEN
						-- Calculate relative coordinates within the block 
						victory_row := row - (game_top + (game_height/2) - 20);
						victory_col := column - (game_left + (game_width/2) - 156);
						-- Get the pixel color from the array
						red   <= victory_image(victory_row, victory_col)(11 DOWNTO 8);
						green <= victory_image(victory_row, victory_col)(7 DOWNTO 4);
						blue  <= victory_image(victory_row, victory_col)(3 DOWNTO 0);
					END IF;
					
				ELSE
				
					-- Draw snake		
					FOR i IN 0 TO max_snake_length - 1 LOOP
						IF i < snake_length THEN
							IF row >= internal_snake(i).y - ((rect_height-1) / 2) AND row <= internal_snake(i).y + ((rect_height-1) / 2) AND
								column >= internal_snake(i).x - ((rect_width-1) / 2) AND column <= internal_snake(i).x + ((rect_width-1) / 2) THEN
								 -- Calculate relative coordinates within the 31x31 block
								snake_row := row - (internal_snake(i).y - ((rect_height-1) / 2));
								snake_col := column - (internal_snake(i).x - ((rect_width-1) / 2));
								-- Get the pixel color from the array
								red   <= snake_image(snake_row, snake_col)(11 DOWNTO 8);
								green <= snake_image(snake_row, snake_col)(7 DOWNTO 4);
								blue  <= snake_image(snake_row, snake_col)(3 DOWNTO 0);
							END IF;
						END IF;
					END LOOP;
					
					-- Draw food 
					IF row >= food_y - ((rect_height-1) / 2) AND row <= food_y + ((rect_height-1) / 2) AND
						column >= food_x - ((rect_width-1) / 2) AND column <= food_x + ((rect_width-1) / 2) THEN
						-- Calculate relative coordinates within the 31x31 block
						food_row := row - (food_y - ((rect_height-1) / 2));
						food_col := column - (food_x - ((rect_width-1) / 2));
						-- Get the pixel color from the array
						red   <= food_image(food_row, food_col)(11 DOWNTO 8);
						green <= food_image(food_row, food_col)(7 DOWNTO 4);
						blue  <= food_image(food_row, food_col)(3 DOWNTO 0);
					END IF;

					-- Draw gray lines for game field border
					IF (row >= game_top AND row <= game_bottom AND (column = game_left OR column = game_right)) OR
						(column >= game_left AND column <= game_right AND (row = game_top OR row = game_bottom)) THEN
						red <= "1000";   
						green <= "1000";
						blue <= "1000";
					END IF;
				
					 -- Draw game lives
					IF lives = 1 THEN
						IF column >= game_left+(game_width/2)-15 AND column <= game_left+(game_width/2)+15 AND
							row >= game_top-41 AND row <= game_top-10 THEN
							-- Calculate relative coordinates within the block
							live_row := row - (game_top-41);
							live_col := column - (game_left+(game_width/2)-15);
							-- Get the pixel color from the array
							red   <= live_image(live_row, live_col)(11 DOWNTO 8);
							green <= live_image(live_row, live_col)(7 DOWNTO 4);
							blue  <= live_image(live_row, live_col)(3 DOWNTO 0);
						END IF;
					ELSIF lives = 2 THEN
						IF column >= game_left+(game_width/2)-30 AND column <= game_left+(game_width/2)+31 AND
							row >= game_top-41 AND row <= game_top-10 THEN
							-- Calculate relative coordinates within the block
							live_row := row - (game_top-41);
							live_col := column - (game_left+(game_width/2)-30);
							-- Get the pixel color from the array
							red   <= live_image(live_row, live_col)(11 DOWNTO 8);
							green <= live_image(live_row, live_col)(7 DOWNTO 4);
							blue  <= live_image(live_row, live_col)(3 DOWNTO 0);
						END IF;
					ELSE
						IF column >= game_left+(game_width/2)-46 AND column <= game_left+(game_width/2)+46 AND
							row >= game_top-rect_width-10 AND row <= game_top-10 THEN
							-- Calculate relative coordinates within the block
							live_row := row - (game_top-41);
							live_col := column - (game_left+(game_width/2)-46);
							-- Get the pixel color from the array
							red   <= live_image(live_row, live_col)(11 DOWNTO 8);
							green <= live_image(live_row, live_col)(7 DOWNTO 4);
							blue  <= live_image(live_row, live_col)(3 DOWNTO 0);
						END IF;
					END IF;
				END IF;
	
			ELSE
			
				-- Draw game over screen
				IF column >= game_left + (game_width/2) - 184 AND column < game_left + (game_width/2) + 184 AND
					row >= game_top + (game_height/2) - 20 AND row < game_top + (game_height/2) + 20 THEN
					-- Calculate relative coordinates within the block
					gameOver_row := row - (game_top + (game_height/2) - 20);
					gameOver_col := column - (game_left + (game_width/2) - 184);
					-- Get the pixel color from the array
					red   <= gameOver_image(gameOver_row, gameOver_col)(11 DOWNTO 8);
					green <= gameOver_image(gameOver_row, gameOver_col)(7 DOWNTO 4);
					blue  <= gameOver_image(gameOver_row, gameOver_col)(3 DOWNTO 0);
				END IF;
				
			END IF;
			
		ELSE  -- Blanking time
			red <= (OTHERS => '0');
			green <= (OTHERS => '0');
			blue <= (OTHERS => '0');
		END IF;
		
	END PROCESS display_logic;
	
END behavior;
