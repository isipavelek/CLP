
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_i2c_master  is
    port (
        RW : in STD_LOGIC;
        busy : out STD_LOGIC;
        enable : in STD_LOGIC;
        reset : in STD_LOGIC;
        scl : out STD_LOGIC;
        sda : inout STD_LOGIC;
        sysclk : in STD_LOGIC
    );

end;


architecture top_i2c_master_arch of top_i2c_master  is
    signal I2C_master_0_I2C_BUSY : STD_LOGIC;
    signal I2C_master_0_SCL : STD_LOGIC;
    signal RW_1 : STD_LOGIC;
    signal btn_1 : STD_LOGIC;
    signal prescaler_0_CLK_OUT : STD_LOGIC;
    signal reset_1 : STD_LOGIC;
    signal sysclk_1 : STD_LOGIC;
    signal DATA_READ1 : STD_LOGIC_VECTOR ( 7 downto 0 );

    component prescaler is
    port (
        CLK_IN : in STD_LOGIC;
        CLK_OUT : out STD_LOGIC
    );
    end component;

    component I2C_master is
    port (
        CLK : in STD_LOGIC;
        ENABLE : in STD_LOGIC;
        RESET : in STD_LOGIC;
        I2C_ADDRESS : in STD_LOGIC_VECTOR ( 6 downto 0 );
        I2C_DATA : in STD_LOGIC_VECTOR ( 7 downto 0 );
        I2C_RW : in STD_LOGIC;
        SDA : inout STD_LOGIC;
        SCL : out STD_LOGIC;
        I2C_BUSY : out STD_LOGIC;
        DATA_READ : out STD_LOGIC_VECTOR ( 7 downto 0 )
    );
    end component;


    begin
    
    RW_1 <= RW;
    btn_1 <= enable;
    busy <= I2C_master_0_I2C_BUSY;
    reset_1 <= reset;
    scl <= I2C_master_0_SCL;
    sysclk_1 <= sysclk;
    u_i2c_master: I2C_master
       port map (
        CLK => prescaler_0_CLK_OUT,
        DATA_READ(7 downto 0) => DATA_READ1(7 downto 0),
        ENABLE => btn_1,
        I2C_ADDRESS(6 downto 0) => B"0100111",
        I2C_BUSY => I2C_master_0_I2C_BUSY,
        I2C_DATA(7 downto 0) => x"AA",
        I2C_RW => RW_1,
        RESET => reset_1,
        SCL => I2C_master_0_SCL,
        SDA => sda
      );
      u_prescaler: prescaler
       port map (
        CLK_IN => sysclk_1,
        CLK_OUT => prescaler_0_CLK_OUT
      );
  end;
