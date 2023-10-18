LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY I2C_tb IS
END ENTITY;

ARCHITECTURE arch OF I2C_tb IS

    COMPONENT I2C_master IS
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
    END COMPONENT;

    SIGNAL CLK : STD_LOGIC := '0';
    SIGNAL ENABLE : STD_LOGIC := '0';
    SIGNAL RESET : STD_LOGIC := '0';
    SIGNAL I2C_ADDRESS : STD_LOGIC_VECTOR(6 DOWNTO 0);
    SIGNAL I2C_DATA : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL I2C_RW : STD_LOGIC;
    SIGNAL SDA : STD_LOGIC;
    SIGNAL SCL : STD_LOGIC;
    SIGNAL I2C_BUSY : STD_LOGIC;
    SIGNAL DATA_READ : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL DATA_READ_SLAVE : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL DATA_SLAVE : STD_LOGIC;
    CONSTANT PERIOD : TIME := 1 ms;

BEGIN

    DUT : I2C_master PORT MAP(
        CLK => CLK,
        ENABLE => ENABLE,
        RESET => RESET,
        I2C_ADDRESS => I2C_ADDRESS,
        I2C_DATA => I2C_DATA,
        I2C_RW => I2C_RW,
        SDA => SDA,
        SCL => SCL,
        I2C_BUSY => I2C_BUSY,
        DATA_READ => DATA_READ

    );

    CLK <= NOT CLK AFTER (PERIOD / 2);
    SDA <= DATA_SLAVE WHEN (I2C_BUSY = '0') ELSE
        'Z';
    I2C_ADDRESS <= "0100111"; --0X27
    I2C_DATA <= "01111010"; --0X7A
    I2C_RW <= '0' AFTER period, '1' AFTER 50 * period;
    DATA_READ_SLAVE <= "11010010"; --0XD2
    ENABLE <= '1' AFTER 4 * period, '0' AFTER 8 * period, '1' AFTER 55 * period, '0' AFTER 60 * period;

    PROCESS
    BEGIN
        DATA_SLAVE <= '0';
        FOR i IN 0 TO 2 LOOP
            WAIT UNTIL I2C_BUSY'event AND I2C_BUSY = '0';
            WAIT FOR period;
        END LOOP;
        WAIT UNTIL I2C_BUSY'event AND I2C_BUSY = '0' AND I2C_RW = '1';
        FOR i IN 0 TO 7 LOOP
            DATA_SLAVE <= DATA_READ_SLAVE(7 - i);
            WAIT UNTIL SCL'event AND SCL = '0';
        END LOOP;
        WAIT;
    END PROCESS;
END arch;