# Documents

Types are defined in documents, which are either local source files or remote network resources. A document may contain either a single type, or one or more type definitions.

Document :
    - Type
    - Definition+

## Definitions

A type definition introduces an alias for a type or imported document. Type aliases, when referred to elsewhere, stand in for the type they define. An import definition allows access to types in another document.

A type alias definition may take one or more type parameters, in which case it is called a *generic*. When referring to a generic type, all its type parameters must be instantiated with type arguments.

Definition :
    - TypeAliasDefinition
    - ImportDefinition

TypeAliasDefinition : Identifier TypeParameters? `=` Type

ImportDefinition : Identifier `=` Import

TypeParameters :
    - `<` `,`? TypeParameterIdentifiers `,`? `>`

TypeParameterIdentifiers :
    - Identifier
    - Identifier `,` TypeParameterIdentifiers

## Types

Type :
    - PrimaryType
    - UnionType
    - OptionalType
    - IntersectionType
    - `(` Type `)`

PrimaryType :
    - StringType
    - NumberType
    - BooleanType
    - NullType
    - AnyType
    - ReferenceType
    - ObjectType
    - ArrayType

### Strings

A string type may be unconstrained, constrained by [bounds](#sec-Length-and-Range-Bounds) on its length, or a singleton type.

StringType :
    - `string`
    - `string` Bounds
    - SingletonStringType

SingletonStringType : StringLiteral

### Numbers

JSONTypes recognises numbers as arbitrary-precision decimals (`number`), arbitrary-precision integers (`integer`), signed 32-bit integers (`int32`) or as 64-bit floating point (`float64`). Number types may be specified to fall within a given range by applying [Bounds]((#sec-Length-and-Range-Bounds)) constraints.

Implementations may choose not to support the `integer` and/or `number` types, whereas the `int32` and `float64` types are mandatory. This is for compatibility reasons, since many JSON libraries do not parse numbers with arbitrary precision by default.

NumberType :
    - DecimalType
    - IntegerType
    - FloatType
    - SingletonNumberType

#### Decimals

The `number` type describes arbitrary-precision decimals.

DecimalType :
    - `number`
    - `number` Bounds


#### Integers

Integers may be arbitrary-precision (`integer`) or signed 32-bit (`int32`). The definition of `int32` is similar to `integer[-2147483648..2147483647]`, though not precisely equivalent due to the rules for type checking of [Bounds Intervals](#sec-Bounds-Intervals).

IntegerType :
    - IntegerTypeName
    - IntegerTypeName Bounds

IntegerTypeName : one of
    integer int32

#### Floating-point Numbers

Values of the `float64` type should be treated as double-precision [IEEE 754](https://ieeexplore.ieee.org/document/4610935) floating-point numbers. However, as in JSON, their lexical {DecimalLiteral} representation does not permit infinities or `NaN` values. 

FloatType :
    - `float64`
    - `float64` Bounds  

#### Singleton Numbers

Singleton number types may be either integer or decimal literals, implicitly using the maximum precision supported by the implementation.

SingletonNumberType :
    - IntegerLiteral
    - DecimalLiteral

### Booleans

BooleanType :
    - `boolean`
    - SingletonBooleanType

SingletonBooleanType :
    - `true`
    - `false`

### Nulls

The `null` type is a singleton distinct from other types. It is useful as a placeholder value or to indicate optionality, and is closer in meaning to the unit type found in functional programming languages.

NullType : `null`

### Any

The `any` type is at the top of the type hierarchy - all other types are subtypes of it.

AnyType : `any`

### References

References point to existing type definitions. Logically a reference may be substituted by the type to which it refers.

When a reference is qualified, the qualifier must refer to an imported document. Qualifiers may not be nested, so referring to an import in an imported document is not allowed.

ReferenceType :
    - Qualifier? Identifier TypeArguments?

Qualifier :
    Identifier `.`

TypeArguments :
    - `<` `,`? Types `,`? `>`

Types :
    - Type
    - Type `,` Types

### Objects

ObjectType :
    - `{` `,`? Fields `,`? `}`
    - AnyObject

AnyObject :
    - `{` `}`
    - `object`

Fields :
    - Field
    - Field `,`? Fields

Field :
    - FieldName `?`? `:` Type

FieldName :
    - Identifier
    - StringLiteral

### Arrays

ArrayType :
    - `array` Bounds? ArrayTypeArgument?
    - ArrayPatternType

ArrayTypeArgument : `<` Type `>`

ArrayPatternType :
    - `[` `,`? Types `,`? `]`
    - `[` `]`

#### Patterns

### Length and Range Bounds

String and array types may be bounded in length by a given interval. Numeric types may be bounded so that their value must fall within a given interval. 

Bounds :
    - `[` BoundsInterval `]`

BoundsInterval :
    - Bounded
    - LeftBounded
    - RightBounded

Bounded : 
    - NumberLiteral
    - NumberLiteral `>`? `..` `<`? NumberLiteral

LeftBounded : NumberLiteral `>`? `..`

RightBounded : `..` `<`? NumberLiteral

#### Intervals

TODO exclusive vs. inclusive, left- vs. right-bounded

An integer bounds interval applies to integer values, or decimal values that may be treated as integers with no precision loss.

A decimal bounds interval applies to both decimal and integer values.

TODO float bounds inclusion?

#### Inclusion

A value is included in a bounds interval if:

TODO

### Unions

Union types represent a choice between types.

UnionType :
    - Type `|` Type

Note: `| `has lower precedence than `&`.

TODO prefix `|`

### Optionals

The optional type is the union of a given type with `null`.

OptionalType :
    Type `?`

### Intersections

An intersection type is the combination of two types 

IntersectionType : Type `&` Type

Note: `&` has higher precedence than `|`.

### Imports

Imports allow types to be reused from other documents.

Import : `import` StringLiteral

TODO importing full URIs vs. relative URIs