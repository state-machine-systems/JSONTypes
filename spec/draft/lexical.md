# Lexical Structure

## Encoding

The source text of a JSONTypes document should be treated as Unicode.

SourceCharacter ::
    - /[\u0021-\u10FFFF]/
    - WhiteSpace

## White Space

WhiteSpace :
    - Space
    - Tab
    - LineEnding

Space : /[\u0020]/

Tab : /[\u0009]/

### Line Endings

For compatibility across platforms, three types of line endings are supported.

LineEnding :
    - LineFeed
    - CarriageReturn [lookahead != LineFeed]
    - CarriageReturn LineFeed

LineFeed : /[\u000A]/

CarriageReturn : /[\u000D]/

### Comments

Comments begin with two hyphens and continue to the next line ending, or to the end of the document if no line ending is present. They may be treated as whitespace, or retained during parsing for later use by other tooling.

Comment :: `--` SourceCharacter but not LineEnding

## Tokens

### Names

{Name}s must start with a letter or an underscore, and can contain letters, numbers, underscores and dashes. This allows for various naming conventions, such as `snake_case`, `kebab-case`, `camelCase` and `PascalCase`.

Name :: /[_A-Za-z][_A-Za-z0-9-]*/

Note: Unicode {Name}s may be supported in a later draft.

### Reserved Words

A reserved word is a {Name} that cannot be used as an {Identifier}.

ReservedWord :: one of
    `any` `array` `boolean` `false` `float64`
    `import` `int32` `integer` `null` `number`
    `object` `string` `true`

### Identifiers

An identifier is a {Name} that is not a {ReservedWord}. 

Identifier :: Name but not ReservedWord

### Strings

JSONTypes uses the same syntax for strings as [JSON](http://json.org/).

StringLiteral :: `"` StringCharacter* `"`

StringCharacter ::
    - SourceCharacter but not `"` or `\` or LineEnding or Tab
    - `\` Escape

Escape :
    - SingleCharacterEscape
    - UnicodeEscape

SingleCharacterEscape : one of
    `"` `\` `/` `b` `n` `r` `t`

UnicodeEscape : `u` /[0-9A-Fa-f]{4}/

### Numbers

JSONTypes uses the same syntax for numbers as [JSON](http://json.org/).

NumberLiteral ::
    - IntegerLiteral
    - DecimalLiteral

#### Integers

IntegerLiteral ::
    - `-`? Digit
    - `-`? NonZeroDigit Digit+

Digit :: /[0-9]/

NonZeroDigit :: /[1-9]/

#### Decimals

DecimalLiteral :: IntegerLiteral `.` Digit+ Exponent?

Exponent ::
    - `E` Sign Digit+
    - `e` Sign Digit+

Sign :: one of
    `+` `-`

### Symbols

The following symbols are used in the JSONTypes grammar:

Symbol :: one of
    `=` `:` `.` `,` `?` `..` `|` `&`
    `{` `}` `[` `]` `<` `>` `(` `)`
