# Whirlyfly

A hardware random number generator for the
[Papilio One](www.papilio.cc)) board based on the
[Whirlygig](http://warmcat.com/_wp/whirlygig-rng/).

## About

The Whirlygig module uses a series of unlocked inverter chains to
generate truly random bits.  These bits are then sent over the
Papilio's serial port to a host computer.

## License

The code added by me is under the GPL.  The following lists the code
that is used, based on, or referenced by the project.

* Whirlygig core: Andy Green @ Crash Barrier Ltd
* Uart driver: Jack Gasset @ Gadget Factory
* Uart core (not included, but referenced): (C) Xilinx Inc.

## Quickstart

The uart side of this project is largly based on Jack Gasset's uart
tutorials for the Papilio One.  I would recommend starting there:
[HighSpeedUart Tutorial](http://papilio.cc/index.php?n=Papilio.HighSpeedUART).

You will need to follow the steps provided in order to add the Xilinx
uart code to the project.

After getting all the code in place, generate the bitstream.

Once the bitstream is generated, load it on the Papilio in the usual
fashion (linux): `papilio-loader -f whirlyfly.bit`

Once the bitfile is loaded, start collecting some random bits!: `dd
bs=1K count=1000 if=/dev/ttyUSB1 of=random_bits.bin`

## Papilio One

The original Whirlygig ran on a Xilinx CPLD and output its data using
8 I/O pins. Those pins were then periodically read by a USB enabled
microcontroller which sent them to the host computer.  This project
adapts the Whirlygig code to run on a Papilio One board. For the
Papilio, it was easiest to just use the on-board USB to serial
adapter.  The Uart core is provided by Xilinx, and runs default at 3M
baud.

The original Whirlygig core had to be modified slightly in order to
compile with the latest Xilinx ISE (tested with 14.1).  In addition to
the `KEEP` attribute applied to the inverters, the `SAVE` attribute
had to be applied as well.  I'm not sure if this is because of the
newer IDE or because of a different target device.


## Testing and Results

The code has been tested on a Papilio One 500K outputting samples at
3M baud.  The output was ran against the [Dieharder]() test suite.
The Papilio passed all tests, just as the original Whirlygig.

## Future work

* Test and tweak the output rate for optimal performance
* Integrate the rng into the
    [Zpuino](http://www.alvie.com/zpuino/index.html) core as a
    hardware extension
* Play with the RNG core, test other inverter configurations, etc.
