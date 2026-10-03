entity add is
    port (
        cin  : in  std_logic;
        a    : in  std_logic_vector(7 downto 0);
        b    : in  std_logic_vector(7 downto 0);
        cout : out std_logic;
        sum  : out std_logic_vector(7 downto 0)
    );
end add;
