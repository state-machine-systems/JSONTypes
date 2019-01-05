# Overview

JSONTypes is a type system for [JSON](http://json.org/) data.

JSONTypes offers a principled approach to JSON validation, built on type theory. Unlike schemas, types can be leveraged to support provably correct data and API evolution. This is achieved via the notion of [subtyping](#sec-Subtype-Relation).

For example, if a data feed returns JSON objects of the following form:

```json example
{
  "id": 123,
  "sequence": 7,
  "unit": "C",
  "value": 17.3
}
```

The feed's developers can publish the following JSONTypes document to describe the type of these objects in detail:

```yaml example
sensor-reading = {
  id: string[36]               -- "id" is a 36-character string
  sequence: int32[0..]         -- "sequence" is a 32-bit integer with minimum value 0
  unit: "C" | "F"              -- "unit" is either C or F
  value: float64               -- "value" is a 64-bit floating point number
}
```

Clients can use this document to validate objects returned by the feed. If the feed evolves in an incompatible way, type checking will fail. The feed's developers can know automatically whether changes are compatible by comparing the two types - if the new type is a subtype of the old one, it is backwards-compatible.

In contrast with type systems found in mainstream programming languages, JSONTypes has a rich feature set including:

* [Union](#sec-Unions) and [intersection](#sec-Intersections) types
* Singleton types, i.e. types that correspond to literal values
* [Bounds](#sec-Length-and-Range-Bounds) on values of numeric types and on lengths of string and array types
* Tuple-like [array patterns](#sec-Patterns)

These features work together to support validation of the diverse forms of JSON data found in real-world APIs.
