v: work unisim
	ghdl --synth --out=verilog --work=work --vendor-library=unisim demo

work: file.vhdl unisim
	ghdl -a --work=work $<

unisim: fake_unisim.vhdl
	ghdl -a --work=unisim $<

clean:
	rm -fr *.cf

