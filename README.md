# ideal.sh
A bash wrapper for checking a directory tree of sub directories containing `.sfv` files and then calculate the checksum and blacklist those whom are deemed unfit. 

## About
This is a POSIX compliant wrapper script in bash which checks folders for sfv and then scans them. Those
who fail will be logged to a file (default: `failed.log`). Ideal is swedish and is a word something near
perfection - which you want your releases to be. It makes use of cksfv for the actual sfv calculations.

### Dependencies

* `~~bc~~`
* `cksfv`

### Usage
The default usage which is `./ideal.sh /path/to/target/` does not touch anything except writing a `failed.log` once `cksfv` is done calculating the checksums. The `failed.log` will be zeroed upon each new scan (read script invocation).

`$ ideal.sh -t /path/to/directory -w -m`

### TBR
#####(Not yet implemented)

```bash

	ideal.sh -t /path/to/target -w -m /tmp

	-w			DANGER: Use with caution. Enables writable mode. Use with --move. 
	-m			Directory to move broken releases into. Ignored unless -w is supplied.
			i	If no argument passed to -m then directory ~/temp is assumed for moving the broken folders to.
	-t			Target path to scan.
	-v			Toggles verbose output. Prints all the juicy stuff.

	-h			Prints this message.

```

### Example output
```bash
$ ideal.sh -t /mnt/music/pop/2003
[▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒                                                       ]
Operation completed 40 scans.
5 broken releases.
35 intact releases.
```

### TODOs

* [] fix bug where dirs with spaces bor
* [x] write a failed rls log
* [] proper args handling
* [/] scrolling output yet with progressbar working(?)
* [] eliminate bc, awk perhaps?
* [] show percentage completion in margin #progressbar
* [] add maxdepth param via cmdline
