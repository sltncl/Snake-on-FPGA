library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY joystick IS

	PORT(
		clock 		: IN STD_LOGIC;
		reset			: IN STD_LOGIC;
		direction 	: OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
	);
				
END joystick;

ARCHITECTURE behave OF joystick IS

	-- Declaration of component 'unnamed'
	COMPONENT unnamed IS
	port (
		CLOCK : in  std_logic                     := '0'; --      clk.clk
		CH0   : out std_logic_vector(11 downto 0);        -- readings.CH0
		CH1   : out std_logic_vector(11 downto 0);        --         .CH1
		CH2   : out std_logic_vector(11 downto 0);        --         .CH2
		CH3   : out std_logic_vector(11 downto 0);        --         .CH3
		CH4   : out std_logic_vector(11 downto 0);        --         .CH4
		CH5   : out std_logic_vector(11 downto 0);        --         .CH5
		CH6   : out std_logic_vector(11 downto 0);        --         .CH6
		CH7   : out std_logic_vector(11 downto 0);        --         .CH7
		RESET : in  std_logic                     := '0'  --    reset.reset
	);
	END COMPONENT;
	
	-- Signals for joystick readings and internal processing
	SIGNAL joystickReadingX,joystickReadingY,c2,c3,c4,c5,c6,c7 : STD_LOGIC_VECTOR(11 downto 0); 
	SIGNAL readX : INTEGER;
	SIGNAL readY : INTEGER;
	
	-- Constants defining joystick behavior
	CONSTANT tolerance : INTEGER := 400; -- Tolerance value for joystick movement detection
	CONSTANT homeX : INTEGER := 2008; -- Center X position of joystick
	CONSTANT homey : INTEGER := 1978; -- Center Y position of joystick

	BEGIN
	
		-- Instantiate the unnamed component
		A0 : unnamed PORT MAP (
			CLOCK => clock, 
			CH0 => joystickReadingX, 
			CH1 => joystickReadingY, 
			CH2 => c2, 
			CH3 => c3, 
			CH4 => c4, 
			CH5 => c5, 
			CH6 => c6, 
			CH7 => c7, 
			RESET => reset
		);
		
		-- Process for joystick direction detection
		my_process: PROCESS(clock)
		BEGIN
			IF rising_edge(clock) THEN
				-- Convert joystick analog readings to integers
				readX <= to_integer(unsigned(joystickReadingX));
				readY <= to_integer(unsigned(joystickReadingY));
				
				-- Determine joystick direction based on analog readings relative to home position
            IF readX > homeX+tolerance THEN  -- Right
					direction <= "01";
            ELSIF readX < homeX-tolerance THEN  -- Left
               direction <= "10";
            ELSIF readY > homeY+tolerance THEN  -- Down
               direction <= "11";
            ELSIF readY < homeY-tolerance THEN  -- Up
               direction <= "00";
            END IF;
				
        END IF;
    END PROCESS my_process;
	END behave;
	
