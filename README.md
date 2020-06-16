# AVRDumper
AVRDumper is a short powershell script to easily (and quickly) dump and reflash avr microcontrollers using avrdude

### usage examples
```
avrdumper.ps1 -processor atmega328p -programmer usbasp
```
to dump and

```
avrdumper.ps1 -processor atmega328p -programmer usbasp -dump 0
```
to (re)flash

### parameters
Name		| Description
------------|------------
processor	| processor to use, avrdude -p, optional will ask
programmer	| programmer to use, avrdude -c, optional will ask
dumpDir		| directory dump files are / will be created in
dump		| dump (1) or flash (0)
dumpRaw		| dump in raw (.bin) or intel hex (.hex) format?

### Disclaimer
These scripts are provided "as is" and are offered without any warranties, but with the hope that the will prove useful to someone.
The developer will not be held responsible for any damage caused by these scripts.

##### TL;DR
Use at your own risk. This script should work, but don't come crying if it doesnt ;)