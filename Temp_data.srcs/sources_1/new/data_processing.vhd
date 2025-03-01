library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity data_processing is
    Port ( aclk : in STD_LOGIC;
           aresetn : in STD_LOGIC;
           btn : in std_logic;
           
           tin_tvalid : in STD_LOGIC;
           tin_tready : out STD_LOGIC;
           tin_tdata : in STD_LOGIC_VECTOR (7 downto 0);
           
           tout_tvalid : out STD_LOGIC;
           tout_tready : in STD_LOGIC;
           tout_tdata : out STD_LOGIC_VECTOR (7 downto 0)
           );
end data_processing;

architecture Behavioral of data_processing is

COMPONENT fifo8x32
  PORT (
    s_axis_aresetn : IN STD_LOGIC;
    s_axis_aclk : IN STD_LOGIC;
    s_axis_tvalid : IN STD_LOGIC;
    s_axis_tready : OUT STD_LOGIC;
    s_axis_tdata : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    m_axis_tvalid : OUT STD_LOGIC;
    m_axis_tready : IN STD_LOGIC;
    m_axis_tdata : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
END COMPONENT;

component filter is
    Port (
        aclk       : in std_logic;
        
        s_axis_tdata  : in std_logic_vector(7 downto 0);
        s_axis_tvalid : in std_logic;                   
        s_axis_tready : out std_logic;                  
        
        m_axis_tdata  : out std_logic_vector(7 downto 0);
        m_axis_tvalid : out std_logic;                   
        m_axis_tready : in std_logic                   
    );
end component;

component aggregation is
    Port (
        aclk               : in std_logic;
        
        s_axis_tdata      : in std_logic_vector(7 downto 0);
        s_axis_tvalid     : in std_logic;
        s_axis_tready     : out std_logic;
        
        m_axis_result_tvalid : OUT STD_LOGIC;
        m_axis_result_tready : IN STD_LOGIC;
        m_axis_result_tdata : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
end component;

component statistics is
  Port (
    aclk : IN STD_LOGIC;
    s_axis_tvalid : IN STD_LOGIC;
    s_axis_tready : OUT STD_LOGIC;
    s_axis_tdata : IN STD_LOGIC_VECTOR(7 DOWNTO 0);

    m_axis_avg_tvalid : OUT STD_LOGIC;
    m_axis_avg_tready : IN STD_LOGIC;
    m_axis_avg_tdata : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);

    m_axis_min_tvalid : OUT STD_LOGIC;
    m_axis_min_tready : IN STD_LOGIC;
    m_axis_min_tdata : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);

    m_axis_max_tvalid : OUT STD_LOGIC;
    m_axis_max_tready : IN STD_LOGIC;
    m_axis_max_tdata : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
end component;

COMPONENT axis_broadcaster_0
  PORT (
    aclk : IN STD_LOGIC;
    aresetn : IN STD_LOGIC;
    s_axis_tvalid : IN STD_LOGIC;
    s_axis_tready : OUT STD_LOGIC;
    s_axis_tdata : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    m_axis_tvalid : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    m_axis_tready : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    m_axis_tdata : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
  );
END COMPONENT;

component display_sequencer is
  Port (
    aclk          : IN STD_LOGIC;
    button        : IN STD_LOGIC;
    
    avg_tvalid    : IN STD_LOGIC;
    avg_tready    : OUT STD_LOGIC;
    avg_tdata     : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    
    min_tvalid    : IN STD_LOGIC;
    min_tready    : OUT STD_LOGIC;
    min_tdata     : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    
    max_tvalid    : IN STD_LOGIC;
    max_tready    : OUT STD_LOGIC;
    max_tdata     : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    
    data_tvalid   : IN STD_LOGIC;
    data_tready   : OUT STD_LOGIC;
    data_tdata    : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    
    m_axis_tvalid : OUT STD_LOGIC;
    m_axis_tready : IN STD_LOGIC;
    m_axis_tdata  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
end component;

signal data_filt : std_logic_vector(7 downto 0);
signal tvalid_filt : std_logic;
signal tready_filt : std_logic;

signal data_fifo1 : std_logic_vector(7 downto 0);
signal tvalid_fifo1 : std_logic;
signal tready_fifo1 : std_logic;

signal data_agr : std_logic_vector(7 downto 0);
signal tvalid_agr : std_logic;
signal tready_agr : std_logic;

signal data_fifo2 : std_logic_vector(7 downto 0);
signal tvalid_fifo2 : std_logic;
signal tready_fifo2 : std_logic;

signal data_brd_1 : std_logic_vector(7 downto 0);
signal tvalid_brd_1 : std_logic;
signal tready_brd_1 : std_logic;

signal data_brd_2 : std_logic_vector(7 downto 0);
signal tvalid_brd_2 : std_logic;
signal tready_brd_2 : std_logic;

signal max_tvalid   : STD_LOGIC;
signal max_tready   : STD_LOGIC;
signal max_tdata    : STD_LOGIC_VECTOR(7 DOWNTO 0);

signal min_tvalid   : STD_LOGIC;
signal min_tready   : STD_LOGIC;
signal min_tdata    : STD_LOGIC_VECTOR(7 DOWNTO 0);

signal avg_tvalid   : STD_LOGIC;
signal avg_tready   : STD_LOGIC;
signal avg_tdata    : STD_LOGIC_VECTOR(7 DOWNTO 0);

begin

filtering : filter 
    port map(
        aclk => aclk,
        s_axis_tdata => tin_tdata,
        s_axis_tvalid => tin_tvalid,
        s_axis_tready => tin_tready,
        m_axis_tdata => data_filt,
        m_axis_tvalid => tvalid_filt,
        m_axis_tready => tready_filt
    );

fifo1 : fifo8x32
  PORT MAP (
    s_axis_aresetn => aresetn,
    s_axis_aclk => aclk,
    s_axis_tvalid => tvalid_filt,
    s_axis_tready => tready_filt,
    s_axis_tdata => data_filt,
    m_axis_tvalid => tvalid_fifo1,
    m_axis_tready => tready_fifo1,
    m_axis_tdata => data_fifo1
  );
  
aggregation_axi : aggregation
    port map(
        aclk => aclk,
        s_axis_tdata => data_fifo1,
        s_axis_tvalid => tvalid_fifo1,
        s_axis_tready => tready_fifo1,
        m_axis_result_tdata => data_agr,
        m_axis_result_tvalid => tvalid_agr,
        m_axis_result_tready => tready_agr
    );

fifo2 : fifo8x32
  PORT MAP (
    s_axis_aresetn => aresetn,
    s_axis_aclk => aclk,
    s_axis_tvalid => tvalid_agr,
    s_axis_tready => tready_agr,
    s_axis_tdata => data_agr,
    m_axis_tvalid => tvalid_fifo2,
    m_axis_tready => tready_fifo2,
    m_axis_tdata => data_fifo2
  );
  
  broadcaster : axis_broadcaster_0
  PORT MAP (
    aclk => aclk,
    aresetn => aresetn,
    s_axis_tvalid => tvalid_fifo2,
    s_axis_tready => tready_fifo2,
    s_axis_tdata => data_fifo2,
    
    m_axis_tvalid(1) => tvalid_brd_1,
    m_axis_tvalid(0) => tvalid_brd_2,
    
    m_axis_tready(1) => tready_brd_1,
    m_axis_tready(0) => tready_brd_2,
    
    m_axis_tdata(15 downto 8) => data_brd_1,
    m_axis_tdata(7 downto 0) => data_brd_2
  );
  
st_calc : statistics
  port map(
    aclk => aclk,
    s_axis_tvalid => tvalid_brd_1,
    s_axis_tready => tready_brd_1,
    s_axis_tdata => data_brd_1,
    
    m_axis_max_tvalid => max_tvalid,
    m_axis_max_tready => max_tready,
    m_axis_max_tdata => max_tdata,

    m_axis_min_tvalid => min_tvalid,
    m_axis_min_tready => min_tready,
    m_axis_min_tdata => min_tdata,

    m_axis_avg_tvalid => avg_tvalid,
    m_axis_avg_tready => avg_tready,
    m_axis_avg_tdata => avg_tdata
  );
  
  switch : display_sequencer
    port map(
    aclk => aclk,
    button => btn,
    
    avg_tvalid => avg_tvalid,
    avg_tready => avg_tready,
    avg_tdata  => avg_tdata,
    
    min_tvalid => min_tvalid,
    min_tready => min_tready,
    min_tdata => min_tdata,
    
    max_tvalid => max_tvalid,
    max_tready => max_tready,
    max_tdata => max_tdata,
    
    data_tvalid => tvalid_brd_2,
    data_tready => tready_brd_2,
    data_tdata => data_brd_2,
    
    m_axis_tvalid => tout_tvalid,
    m_axis_tready => tout_tready,
    m_axis_tdata => tout_tdata
    );

end Behavioral;
