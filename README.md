# Zig Password Generator (zigpwgen)

`zigpwgen` is a flexible password generator designed to produce passphrases that balance security and pronounceability. It is based on a pattern system where words, tokens, symbols, and digits can be flexibly combined. Built with the Zig programming language, `zigpwgen` ensures performance, clarity, and simplicity.

## Features
- **Pronounceable Words**: Uses tokens from the EFF long word list to generate memorable passphrases.
- **Customizable Patterns**: Define your own password structure using a simple pattern syntax.
- **Efficient and Fast**: Built with Zig, ensuring minimal runtime overhead and clear, maintainable code.

## Installation

Clone the repository and build with Zig:

```sh
git clone https://github.com/francescoalemanno/zigpwgen.git
cd zigpwgen
zig build -Doptimize=ReleaseFast
```

## Usage

### Command Syntax

```sh
Usage: zigpwgen [-p <pattern>] [-n <num>] [-e]

Flexible password generator using the EFF long word list for pronounceable words. 
Built with Zig for performance and simplicity.

Options:
  -p, --pattern     string representing the desired structure of the generated passphrases,
                    defaults to `W-w-w-w-ds` (w = word; t = token; s = symbol; d = digit).

  -n, --num         number of passphrases to generate,
                    defaults to 5.

  -e, --entropy     print entropy in base log2 along with the generated password,
                    defaults to false.
                    
  --help            display usage information

  -----------------------------------------------------------------------------------------
  author: Francesco Alemanno <francescolemanno710@gmail.com>.
  repo:   https://github.com/francescoalemanno/zigpwgen
```

# License

MIT License

Copyright (c) 2024 Francesco Alemanno
