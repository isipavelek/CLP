LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY prescaler IS
    generic(
        PRESCALER_VALUE : integer := 125000
    );     
    PORT (
        CLK_IN : IN STD_LOGIC;
        CLK_OUT : OUT STD_LOGIC
    );
END prescaler;

ARCHITECTURE prescaler_arch OF prescaler IS
    SIGNAL COUNT : INTEGER := 1;
    SIGNAL TMP : STD_LOGIC := '0';
BEGIN

    PROCESS (CLK_IN,TMP)
    BEGIN

        IF (CLK_IN'event AND CLK_IN = '1') THEN
            COUNT <= COUNT + 1;
            IF (COUNT = PRESCALER_VALUE) THEN
                TMP <= NOT TMP;
                COUNT <= 1;
            END IF;
        END IF;
        CLK_OUT <= TMP;
    END PROCESS;
END prescaler_arch;