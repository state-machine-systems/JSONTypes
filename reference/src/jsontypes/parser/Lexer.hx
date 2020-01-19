package jsontypes.parser;

typedef Token = { tokenType: TokenType, pos: hxparse.Position };

enum TokenType {
    Keyword(value: KeywordType);
    Name(value: String);
    Number(value: String);
    String(value: String);
    LParen;
    RParen;
    LBracket;
    RBracket;
    LBrace;
    RBrace;
    LAngle;
    RAngle;
    Colon;
    QMark;
    DotDot;
    Dot;
    Comma;
    Equals;
    Pipe;
    Ampersand;
}

enum KeywordType {
    Any;
    Array;
    Boolean;
    Decimal;
    False;
    Float;
    Import;
    Int;
    Integer;
    Null;
    Object;
    String;
    True;
}

class Lexer extends hxparse.Lexer implements hxparse.RuleBuilder {

    public static final rules = @:rule [
        "[_a-zA-Z](-?[_a-zA-Z0-9]+)*" => { tokenType: nameOrKeyword(lexer.current), pos: lexer.curPos() },
        "-?([0-9]|[1-9][0-9]+)(\\.[0-9]+([eE][-+][0-9]+)?)?" => { tokenType: TokenType.Number(lexer.current), pos: lexer.curPos() },
        "\"" => {
            final startPos = lexer.pos - 1;
            final buf = new StringBuf();
            while (true) {
                final code = lexer.token(Lexer.stringCharacter);
                if (code == -1) {
                    break;
                } else {
                    buf.addChar(code);
                }
            }
            final pos = new hxparse.Position(lexer.source, startPos, lexer.pos);
            { tokenType: TokenType.String(buf.toString()), pos: pos };
        },
        "[\r\n\t ]" => lexer.token(Lexer.rules),
        "--[^\r\n]*[\r\n]" => lexer.token(Lexer.rules),
        "\\(" => { tokenType: TokenType.LParen, pos: lexer.curPos() },
        "\\)" => { tokenType: TokenType.RParen, pos: lexer.curPos() },
        "\\[" => { tokenType: TokenType.LBracket, pos: lexer.curPos() },
        "\\]" => { tokenType: TokenType.RBracket, pos: lexer.curPos() },
        "\\{" => { tokenType: TokenType.LBrace, pos: lexer.curPos() },
        "\\}" => { tokenType: TokenType.RBrace, pos: lexer.curPos() },
        "<" => { tokenType: TokenType.LAngle, pos: lexer.curPos() },
        ">" => { tokenType: TokenType.RAngle, pos: lexer.curPos() },
        ":" => { tokenType: TokenType.Colon, pos: lexer.curPos() },
        "\\?" => { tokenType: TokenType.QMark, pos: lexer.curPos() },
        "\\.\\." => { tokenType: TokenType.DotDot, pos: lexer.curPos() },
        "\\." => { tokenType: TokenType.Dot, pos: lexer.curPos() },
        "," => { tokenType: TokenType.Comma, pos: lexer.curPos() },
        "=" => { tokenType: TokenType.Equals, pos: lexer.curPos() },
        "|" => { tokenType: TokenType.Pipe, pos: lexer.curPos() },
        "&" => { tokenType: TokenType.Ampersand, pos: lexer.curPos() },
    ];

    @:nullSafety(Off)
    private static final stringCharacter = @:rule [
        "\\\\b" => 8,
        "\\\\n" => 10,
        "\\\\f" => 12,
        "\\\\r" => 13,
        "\\\\t" => 9,
        "\\\\\"" => 34,
        "\\\\\\\\" => 92,
        "\\\\u[0-9A-Fa-f]{4}" => Std.parseInt("0x" + lexer.current.substr(2)),
        "[^\"]" => lexer.current.charCodeAt(0),
        "\"" => -1,
    ];

    private static function nameOrKeyword(input: String): TokenType {
        return switch input {
            case "any": TokenType.Keyword(KeywordType.Any);
            case "array": TokenType.Keyword(KeywordType.Array);
            case "boolean": TokenType.Keyword(KeywordType.Boolean);
            case "decimal": TokenType.Keyword(KeywordType.Decimal);
            case "false": TokenType.Keyword(KeywordType.False);
            case "float": TokenType.Keyword(KeywordType.Float);
            case "import": TokenType.Keyword(KeywordType.Import);
            case "int": TokenType.Keyword(KeywordType.Int);
            case "integer": TokenType.Keyword(KeywordType.Integer);
            case "null": TokenType.Keyword(KeywordType.Null);
            case "object": TokenType.Keyword(KeywordType.Object);
            case "string": TokenType.Keyword(KeywordType.String);
            case "true": TokenType.Keyword(KeywordType.True);
            default: TokenType.Name(input);
        }
    }
}
