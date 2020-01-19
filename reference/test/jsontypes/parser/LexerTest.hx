package jsontypes.parser;

import jsontypes.common.Pair;
import jsontypes.parser.Lexer.KeywordType;
import haxe.ds.Option;
import byte.ByteData;
import haxe.io.Eof;
import utest.Assert;
import utest.Test;
import hxcheck.Gen;
import hxcheck.Props.forAll;
import jsontypes.parser.Lexer.TokenType;
import String.fromCharCode;

typedef Input = Array<Pair<String, hxparse.Position>>;

class LexerTest extends Test {

    function testLexer() {
        forAll(genArrayOfTokenTypes(), expectedTokenTypes -> {
            var input = buildInput(expectedTokenTypes);
            var inputData = ByteData.ofString(input.map(pair -> pair.first).join(''));
            var lexer = new Lexer(inputData, "test");

            trace("********************************************************************************");
            trace("\nInput:    [" + inputData  + "]");
            trace("\nExpected: " + expectedTokenTypes);

            var tokens = [];
            try while (true) tokens.push(lexer.token(Lexer.rules))
            catch (ex: Eof) {}

            var actualTokenTypes = tokens.map(token -> token.tokenType);
            var actualPositions = tokens.map(token -> token.pos);
            var expectedPositions = input.map(pair -> pair.second);
            trace("\nActual:   " + actualTokenTypes);
            Assert.same(expectedTokenTypes, actualTokenTypes);
            Assert.same(expectedPositions, actualPositions);
        });
    }

    function buildInput(tokenTypes: Array<TokenType>): Input {
        var lineEnding = Gen.oneOf([
            Gen.const("\n"),
            Gen.const("\r"),
            Gen.const("\r\n")
        ]);
        var comment = Gen.arrayOf(genTokenType(), 10)
            .map(tokenTypes -> "--" + tokenTypes.map(tokenTypeToString).join('') + lineEnding.generate());
        var maybeWhitespace = Gen.maybe(Gen.oneOf([
            Gen.const(" "),
            Gen.const("\t"),
            lineEnding,
            comment
        ])).map(orEmpty);

        var input = [];
        var pos = 0;
        for (t in tokenTypes) {
            var leadingWhitespace = maybeWhitespace.generate();
            pos += leadingWhitespace.length;
            var startPos = pos;
            var token = tokenTypeToString(t);
            pos += token.length;
            var endPos = pos;
            var trailingWhitespace = maybeWhitespace.generate();
            pos += trailingWhitespace.length;

            input.push(new Pair(leadingWhitespace + token + trailingWhitespace, new hxparse.Position("test", startPos, endPos)));
        }

        return input;
    }

    function genArrayOfTokenTypes(): Gen<Array<TokenType>> {
        return Gen.arrayOf(genTokenType()).map(tokenTypes -> {
            var i = 0;
            while (i < tokenTypes.length) {
                var j = i + 1;
                var advance = true;
                if (j < tokenTypes.length) {
                    switch [tokenTypes[i], tokenTypes[j]] {
                        case [Dot, DotDot]:
                            tokenTypes[i] = DotDot;
                            tokenTypes[j] = Dot;
                        case [Dot, Dot]:
                            tokenTypes[i] = DotDot;
                            tokenTypes.splice(j, 1);
                        case [Name(_), Name(_)]:
                            tokenTypes.splice(j, 1);
                            advance = false;
                        case [Name(_), Keyword(_)]:
                            tokenTypes.splice(j, 1);
                            advance = false;
                        case [Keyword(_), Name(_)]:
                            tokenTypes.splice(j, 1);
                            advance = false;
                        case [Keyword(_), Keyword(_)]:
                            tokenTypes.splice(j, 1);
                            advance = false;
                        case [Name(_), Number(_)]:
                            tokenTypes.splice(j, 1);
                            advance = false;
                        case [Keyword(_), Number(_)]:
                            tokenTypes.splice(j, 1);
                            advance = false;
                        case [Number(_), name = Name(value)]:
                            if (value.charAt(0) == "e" || value.charAt(0) == "E") {
                                tokenTypes.splice(j, 1);
                                advance = false;
                            }
                        case [Number(_), Number(_)]:
                            tokenTypes.splice(j, 1);
                            advance = false;
                        case [Number(value), Dot]:
                            if (value.indexOf(".") < 0) {
                                tokenTypes.splice(j, 1);
                                advance = false;
                            }
                        case [_, _]:
                    }
                }
                if (advance) i++;
            }
            tokenTypes;
        });
    }

    function genTokenType(): Gen<TokenType> {
        return Gen.oneOf([
            genKeyword(),
            genName(),
            genNumber(),
            genString(),
            Gen.const(LParen),
            Gen.const(RParen),
            Gen.const(LBracket),
            Gen.const(RBracket),
            Gen.const(LBrace),
            Gen.const(RBrace),
            Gen.const(LAngle),
            Gen.const(RAngle),
            Gen.const(Colon),
            Gen.const(QMark),
            Gen.const(DotDot),
            Gen.const(Dot),
            Gen.const(Comma),
            Gen.const(Equals),
            Gen.const(Pipe),
            Gen.const(Ampersand),
        ]);
    }

    function genKeyword(): Gen<TokenType> {
        return Gen.choose([
            TokenType.Keyword(KeywordType.Any),
            TokenType.Keyword(KeywordType.Array),
            TokenType.Keyword(KeywordType.Boolean),
            TokenType.Keyword(KeywordType.Decimal),
            TokenType.Keyword(KeywordType.False),
            TokenType.Keyword(KeywordType.Float),
            TokenType.Keyword(KeywordType.Import),
            TokenType.Keyword(KeywordType.Int),
            TokenType.Keyword(KeywordType.Integer),
            TokenType.Keyword(KeywordType.Null),
            TokenType.Keyword(KeywordType.Object),
            TokenType.Keyword(KeywordType.String),
            TokenType.Keyword(KeywordType.True)
        ]);
    }

    function genName(): Gen<TokenType> {
        var identStart = [Gen.chars('a', 'z'), Gen.chars('A', 'Z'), Gen.const('_')];
        var identPart = Gen.nonEmptyArrayOf(Gen.oneOf(identStart.concat([Gen.chars('0', '9')])), 5).map(join);
        var separatedIdentPart = identPart.map(chars -> '-' + chars);

        var keywords = [
            "any", "array", "boolean", "decimal", "false", "float", "import", "int", "integer", "null", "object", "string", "true"
        ];
        return Gen.oneOf(identStart).flatMap(first -> {
            Gen.arrayOf(Gen.oneOf([identPart, separatedIdentPart]), 5)
                .map(rest -> first + join(rest))
                .filter(name -> keywords.indexOf(name) == -1)
                .map(Name);
        });
    }

    function genNumber(): Gen<TokenType> {
        var maybeNegativeSign = Gen.maybe(Gen.const('-')).map(orEmpty);
        var singleDigit = Gen.chars('0', '9');
        var digits = Gen.nonEmptyArrayOf(singleDigit, 10).map(join);

        var integerStartingWithNonZero = Gen.chars('1', '9').flatMap(first -> digits.map(rest -> first + rest));

        var integerComponent = Gen.oneOf([singleDigit, integerStartingWithNonZero]);

        var maybeExponent = Gen.maybe(Gen.choose(['e', 'E']).flatMap(e -> {
            Gen.choose(['-', '+']).flatMap(sign -> digits.map(exponentDigits -> e + sign + exponentDigits));
        })).map(orEmpty);

        var decimalComponent = Gen.maybe(digits.flatMap(decimalDigits -> {
            maybeExponent.map(exponent -> '.' + decimalDigits + exponent);
        })).map(orEmpty);

        return integerComponent.flatMap(first -> decimalComponent.map(rest -> Number(first + rest)));
    }

    function genString(): Gen<TokenType> {
        var space = fromCharCode(32);
        var delete = fromCharCode(127);
        var unescapedChars = Gen.chars(space, delete);
        var hexChars = Gen.oneOf([Gen.chars('0', '9'), Gen.chars('a', 'f'), Gen.chars('A', 'F')]);
        var unicodeEscape = Gen.arrayOfN(hexChars, 4).map(chars -> "\\u" + join(chars));
        var escapes = Gen.oneOf([
            Gen.const("\\\""),
            Gen.const("\\\\"),
            Gen.const("\\/"),
            Gen.const("\\b"),
            Gen.const("\\f"),
            Gen.const("\\n"),
            Gen.const("\\r"),
            Gen.const("\\t"),
            unicodeEscape
        ]);
        return Gen.arrayOf(Gen.oneOf([unescapedChars, escapes]), 10)
            .map(parts -> String(join(parts)));
    }

    function join(strings: Array<String>): String {
        return strings.join('');
    }

    function orEmpty(option: Option<String>): String {
        return switch option {
            case Some(string): string;
            case None: '';
        }
    }

    function tokenTypeToString(tokenType: TokenType): String {
        return switch(tokenType) {
            case Keyword(Any): "any";
            case Keyword(Array): "array";
            case Keyword(Boolean): "boolean";
            case Keyword(Decimal): "decimal";
            case Keyword(False): "false";
            case Keyword(Float): "float";
            case Keyword(Import): "import";
            case Keyword(Int): "int";
            case Keyword(Integer): "integer";
            case Keyword(Null): "null";
            case Keyword(Object): "object";
            case Keyword(String): "string";
            case Keyword(True): "true";
            case Name(value): value;
            case Number(value): value;
            case String(value): {
                var buf = new StringBuf();
                buf.add('"');
                for (i in 0...value.length) {
                    @:nullSafety(Off) switch value.charCodeAt(i) {
                        case 8: buf.add("\\b");
                        case 9: buf.add("\\t");
                        case 10: buf.add("\\n");
                        case 12: buf.add("\\f");
                        case 13: buf.add("\\r");
                        case 34: buf.add("\\\"");
                        case 92: buf.add("\\\\");
                        case other: buf.addChar(other);
                    }
                }
                buf.add('"');
                buf.toString();
            };
            case LParen: "(";
            case RParen: ")";
            case LBracket: "[";
            case RBracket: "]";
            case LBrace: "{";
            case RBrace: "}";
            case LAngle: "<";
            case RAngle: ">";
            case Colon: ":";
            case QMark: "?";
            case DotDot: "..";
            case Dot: ".";
            case Comma: ",";
            case Equals: "=";
            case Pipe: "|";
            case Ampersand: "&";
        };
    }
}
