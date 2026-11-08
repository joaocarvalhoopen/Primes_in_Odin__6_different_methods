all:
	odin build prime_numbers.odin -file -out:pnum.exe \
       -o:speed -no-bounds-check -microarch:native -lto:thin

clean:
	rm -f ./pnum.exe

run:
	./pnum.exe
