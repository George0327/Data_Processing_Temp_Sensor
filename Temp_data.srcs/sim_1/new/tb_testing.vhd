library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.textio.ALL;

entity testing_tb is
end testing_tb;

architecture Behavioral of testing_tb is

    component testing
        Port (
            aclk : in STD_LOGIC;
            aresetn : in STD_LOGIC;
            btn : in std_logic;
            tin_tvalid : in STD_LOGIC;
            tin_tready : out STD_LOGIC;
            tin_tdata : in STD_LOGIC_VECTOR (7 downto 0);
            tout_tvalid : out STD_LOGIC;
            tout_tready : in STD_LOGIC;
            tout_tdata : out STD_LOGIC_VECTOR (7 downto 0);
            tout_tvalid1 : out STD_LOGIC;
            tout_tready1 : in STD_LOGIC;
            tout_tdata1 : out STD_LOGIC_VECTOR (7 downto 0);
            tout_tvalid2 : out STD_LOGIC;
            tout_tready2 : in STD_LOGIC;
            tout_tdata2 : out STD_LOGIC_VECTOR (7 downto 0);
            tout_tvalid3 : out STD_LOGIC;
            tout_tready3 : in STD_LOGIC;
            tout_tdata3 : out STD_LOGIC_VECTOR (7 downto 0)
        );
    end component;

    signal aclk : STD_LOGIC := '0';
    signal aresetn : STD_LOGIC := '0';
    signal btn : STD_LOGIC := '0';

    signal tin_tvalid : STD_LOGIC := '0';
    signal tin_tready : STD_LOGIC;
    signal tin_tdata : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');

    signal tout_tvalid : STD_LOGIC;
    signal tout_tready : STD_LOGIC := '1';
    signal tout_tdata : STD_LOGIC_VECTOR (7 downto 0);

    signal tout_tvalid1 : STD_LOGIC;
    signal tout_tready1 : STD_LOGIC := '1';
    signal tout_tdata1 : STD_LOGIC_VECTOR (7 downto 0);

    signal tout_tvalid2 : STD_LOGIC;
    signal tout_tready2 : STD_LOGIC := '1';
    signal tout_tdata2 : STD_LOGIC_VECTOR (7 downto 0);

    signal tout_tvalid3 : STD_LOGIC;
    signal tout_tready3 : STD_LOGIC := '1';
    signal tout_tdata3 : STD_LOGIC_VECTOR (7 downto 0);

    constant CLK_PERIOD : time := 10 ns;

    -- File I/O
    file input_file : text open read_mode is "temperature_measurements.csv";
    shared variable line_content : line;
    shared variable data_value : integer;

begin
    uut: testing
        Port map (
            aclk => aclk,
            aresetn => aresetn,
            btn => btn,
            tin_tvalid => tin_tvalid,
            tin_tready => tin_tready,
            tin_tdata => tin_tdata,
            tout_tvalid => tout_tvalid,
            tout_tready => tout_tready,
            tout_tdata => tout_tdata,
            tout_tvalid1 => tout_tvalid1,
            tout_tready1 => tout_tready1,
            tout_tdata1 => tout_tdata1,
            tout_tvalid2 => tout_tvalid2,
            tout_tready2 => tout_tready2,
            tout_tdata2 => tout_tdata2,
            tout_tvalid3 => tout_tvalid3,
            tout_tready3 => tout_tready3,
            tout_tdata3 => tout_tdata3
        );

    -- Clock generation
    clk_process : process
    begin
        aclk <= '0';
        wait for CLK_PERIOD / 2;
        aclk <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    -- Stimulus process
    stimulus_process : process
    begin
        aresetn <= '0';
        wait for 20 ns;
        aresetn <= '1';

        while not endfile(input_file) loop
            readline(input_file, line_content);
            read(line_content, data_value);

            tin_tdata <= std_logic_vector(to_unsigned(data_value, 8));
            tin_tvalid <= '1';
            wait until rising_edge(aclk);

            wait until tin_tready = '1';
            tin_tvalid <= '0';
        end loop;

        -- Finish simulation
        wait for 100 ns;
        assert false report "Simulation finished" severity note;
        wait;
    end process;

end Behavioral;
