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
zigpwgen [-p <pattern>] [-n <num>]
```

### Options

- `-p, --pattern <pattern>`  
  Defines the structure of the generated passphrases. The default pattern is `w.w.w.ddss`.  
  - `W` - a pseudo-word (uppercase)
  - `w` - a pseudo-word (lowercase)
  - `t` - a token (lowercase)
  - `T` - a token (starting with an uppercase letter)
  - `s` - a symbol (e.g., `!`, `$`, `%`)
  - `d` - a digit (0-9)

- `-n, --num <num>`  
  Specifies the number of passphrases to generate. Default is `5`.

- `--help`  
  Displays usage information.

### Example

To generate 3 passwords with a custom pattern:

```sh
zigpwgen -p "Tt.ss.dd" -n 3
```

This generates three passphrases where:
- `T` starts with an uppercase token,
- `t` is a lowercase token,
- `s` is a symbol, and
- `d` is a digit.

### Default Pattern

If no pattern is provided, the default pattern `w.w.w.ddss` is used, which produces three words, followed by two digits and two symbols. For example:

```
apple.banana.orange.42$%
```

### Help

For a full list of options and usage, use:

```sh
zigpwgen --help
```
