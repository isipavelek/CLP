LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY I2C_master IS
    PORT (
        CLK : IN STD_LOGIC;
        ENABLE : IN STD_LOGIC;
        RESET : IN STD_LOGIC;
        I2C_ADDRESS : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
        I2C_DATA : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        I2C_RW : IN STD_LOGIC;
        SDA : INOUT STD_LOGIC;
        SCL : OUT STD_LOGIC;
        I2C_BUSY : OUT STD_LOGIC;
        DATA_READ : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
END I2C_master;

ARCHITECTURE I2C_master_arch OF I2C_master IS
    TYPE States IS(IDLE, START_STATE, ADDR, WRITE_DATA, READ_DATA, SLAVE_ACK, WRITE_ACK, READ_NACK, CLK_STATE, STOP_STATE);
    SIGNAL STATE : States := IDLE;
    SIGNAL STATE_PREV : States := IDLE;
    SIGNAL ADDR_SHIFT : STD_LOGIC_VECTOR(6 DOWNTO 0);
    SIGNAL DATA_SHIFT : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL SIG_RW : STD_LOGIC;
    SIGNAL COUNT : unsigned(3 DOWNTO 0) := "0000";
BEGIN
    PROCESS (clk, RESET)
    BEGIN
        IF RESET = '1' THEN
            SDA <= '1';
            SCL <= '1';
            COUNT <= x"0";
            STATE <= IDLE;
            I2C_BUSY <= '1';
            DATA_READ <= x"00";
            ADDR_SHIFT <= "0000000";
            DATA_SHIFT <= x"00";
            SIG_RW <= '0';
            STATE_PREV <= IDLE;
        ELSIF (clk'event AND clk = '0') THEN
            STATE_PREV <= STATE;
            CASE STATE IS
                WHEN IDLE =>
                    I2C_BUSY <= '1';
                    SDA <= '1';
                    SCL <= '1';
                    IF ENABLE = '1' THEN
                        ADDR_SHIFT <= I2C_ADDRESS;--ADDRESS
                        DATA_SHIFT <= I2C_DATA;--DATA_OUT; 
                        SIG_RW <= I2C_RW;--RW;--I2C_RW; 
                        STATE <= START_STATE;
                    ELSE
                        STATE <= IDLE;
                    END IF;
                WHEN START_STATE =>
                    I2C_BUSY <= '1';
                    SDA <= '0';
                    STATE <= ADDR;
                WHEN ADDR =>

                    IF COUNT < x"7" THEN
                        SCL <= '0';
                        SDA <= ADDR_SHIFT(6);
                        ADDR_SHIFT(6 DOWNTO 0) <= ADDR_SHIFT(5 DOWNTO 0) & '0';
                        COUNT <= COUNT + 1;
                        STATE <= CLK_STATE;

                    ELSIF COUNT = x"7" THEN
                        SCL <= '0';
                        SDA <= SIG_RW;
                        COUNT <= COUNT + 1;
                        STATE <= CLK_STATE;

                    ELSIF COUNT = x"8" THEN --ACK
                        I2C_BUSY <= '0';
                        SDA <= 'Z';
                        SCL <= '0';
                        STATE <= SLAVE_ACK;

                    ELSIF COUNT < x"B" THEN
                        I2C_BUSY <= '1';
                        SDA <= '1';
                        SCL <= '0';
                        COUNT <= COUNT + 1;
                        STATE <= ADDR;

                    ELSE
                        SCL <= '0';
                        COUNT <= x"0";

                        IF SIG_RW = '0' THEN
                            STATE <= WRITE_DATA;
                        ELSE
                            I2C_BUSY <= '0';
                            SDA <= 'Z';
                            STATE <= READ_DATA;
                        END IF;
                    END IF;

                WHEN SLAVE_ACK =>
                    SCL <= '1';
                    IF (SDA == '1') THEN
                        STATE <= IDDLE;
                    ELSE
                        COUNT <= COUNT + 1;
                        STATE <= ADDR;
                    END IF;
                WHEN WRITE_DATA =>
                    IF COUNT < x"8" THEN
                        SCL <= '0';
                        SDA <= DATA_SHIFT(7);
                        DATA_SHIFT(7 DOWNTO 0) <= DATA_SHIFT(6 DOWNTO 0) & 'U';
                        COUNT <= COUNT + 1;
                        STATE <= CLK_STATE;

                    ELSIF count = x"8" THEN
                        I2C_BUSY <= '0';
                        SDA <= 'Z';
                        SCL <= '0';
                        STATE <= WRITE_ACK;
                    END IF;

                WHEN WRITE_ACK =>
                    SCL <= '1';
                    IF (SDA == '1') THEN
                        STATE <= IDDLE;
                    ELSE
                        COUNT <= COUNT + 1;
                        STATE <= STOP_STATE;
                    END IF;
                WHEN READ_DATA =>
                    IF COUNT < x"8" THEN
                        SCL <= '1';
                        DATA_SHIFT(7 DOWNTO 0) <= DATA_SHIFT(6 DOWNTO 0) & SDA;
                        COUNT <= COUNT + 1;
                        STATE <= CLK_STATE;

                    ELSIF COUNT = x"8" THEN --NACK
                        SCL <= '0';
                        DATA_READ <= DATA_SHIFT;
                        SDA <= '1';
                        COUNT <= COUNT + 1;
                        STATE <= READ_NACK;
                    END IF;

                WHEN READ_NACK =>
                    IF (COUNT = x"9") THEN
                        SCL <= '1';
                        COUNT <= COUNT + 1;
                        STATE <= CLK_STATE;
                    ELSE
                        SDA <= '0';
                        STATE <= STOP_STATE;

                    END IF;
                WHEN STOP_STATE =>
                    I2C_BUSY <= '1';
                    SCL <= '1';
                    COUNT <= x"0";
                    STATE <= IDLE;

                WHEN CLK_STATE =>
                    IF STATE_PREV = READ_DATA OR STATE_PREV = READ_NACK THEN
                        SCL <= '0';
                    ELSE
                        SCL <= '1';
                    END IF;
                    STATE <= STATE_PREV;
                WHEN OTHERS =>
                    STATE <= IDLE;
            END CASE;
        END IF;
    END PROCESS;
END I2C_master_arch;