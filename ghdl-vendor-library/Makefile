v: work-obj08.cf unisim-obj08.cf
	ghdl --synth --std=08 --out=verilog --work=work --vendor-library=unisim demo

v2: work-obj08.cf unisim-obj08.cf
	ghdl --synth --std=08 --out=verilog --work=work demo

work-obj08.cf: file.vhdl unisim-obj08.cf
	ghdl -a --std=08 --work=work $<

unisim-obj08.cf: fake_unisim.vhdl
	ghdl -a --std=08 --work=unisim $<

clean:
	rm -fr *.cf

