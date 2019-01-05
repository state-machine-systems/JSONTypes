# Typing Rules

## Subtype Relation


TODO safe substitution principle, S is a subtype of T, written S <: T, if a value of type S can safely be used in any context where a value of type T is expected (Pierce)

TODO see https://www.seas.upenn.edu/~cis500/current/sf/plf-current/Sub.html

Reflexivity ::: T <: T

Transitivity ::: Given T <: U and U <: V, T <: V

All types are subtypes of themselves.

TODO top and bottom types

TODO quick intro to subtyping

## Any

All types are subtypes of {Any}.

## Strings

A string type *T* is a subtype of another string type *U* if:

* *U* is the unconstrained `string` type;
* or *T* and *U* both have length bounds, and *T*&#8217;s bounds are a [subinterval](#sec-Bounds-Intervals) of *U*&#8217;s;
* or *T* and *U* are both singletons with [equal](#sec-String-Equality) values;
* or *T* is a singleton and *U* has a length bound that includes *T*&#8217;s length.

### String Equality

TODO same codepoints

## Numbers

A number type *T* is a subtype of another number type *U* if:

* *U* is the unconstrained decimal `number` type;
* or *T* and *U* are both decimal types and *T* is a subtype of *U*;
* or *T* and *U* are both integer types and *T* is a subtype of *U*;
* or *T* is an integer type and *U* is a decimal type and *T*, when promoted to a decimal, is a subtype of *U*.

TODO or *T* is a decimal type and *U* is an integer type and *T* may be treated as an integer with no loss of precision.

 both are integer types, both are decimal types, or *T* is an integer type and *U* is a decimal type, and:

* *U* is the unconstrained `number` type;
* or *T* and *U* both have range bounds, and *T*&#8217;s bounds are a [subinterval](#sec-Bounds-Intervals) of *U*&#8217;s.

* or *T* and *U* are both singletons with [equivalent](#sec-Number-Equivalence) literal values;

TODO literal <: bounded
TODO bounded <: literal

TODO better notation?

* `integer[`<i>bounds<sub>1</sub></i>`]` <: `integer[`<i>bounds<sub>2</sub></i>`]` if <i>bounds<sub>1</sub></i> <: <i>bounds<sub>2</sub></i>
* {Integer}<sub>1</sub> <: {Integer}<sub>2</sub> if both are equivalent values

### Number Equivalence

TODO treat decimal representable as integer without precision loss as equivalent?

## Booleans

A boolean type *T* is a subtype of another boolean type *U* if:

* *U* is the unconstrained `boolean` type;
* or *T* and *U* are the same literal value.

## Nulls

A null type is only a subtype of another null type.

## Objects

An object type *T* is a subtype of another object type *U* if:

* *U* is the "any object" type: `{}` or `object`;
* or for each field *u* defined in *U*, there is a field *t* defined in *T* such that:
  * *t*&#8217;s name is [equal](#sec-String-Equality) to *u*&#8217;s name;
  * and *t*&#8217;s type is a subtype of *u*&#8217;s;
  * and both *t* and *u* are optional, both *t* and *u* are mandatory, or *t* is mandatory and *u* is optional.

## Arrays

An array type *T* is a subtype of another array type *U* if:

* *U* is the "any array" type: `array`;
* or *U* is unbounded and *T*&#8217;s element type is a subtype of *U*&#8217;s;
* or *T*&#8217;s bounds are a [subinterval](#sec-Bounds-Intervals) of *U*&#8217;s and *T*&#8217;s element type is a subtype of *U*&#8217;s;
* or both *T* and *U* are array patterns of the same length and each element of *T* is a subtype of the corresponding element in *U*;
* or *T* is an array pattern and each element in *T* is a subtype of *U*&#8217;s element type and *U* is either unbounded or *T*&#8217;s length is included in *U*&#8217;s bounds.

TODO `array[bounds]<t>` vs. pattern

## Bounds Intervals

Bounds interval *T* is a subinterval of another bounds interval *U* if:

* *T*&#8217;s lower bound is a [sub-bound](#sec-Lower-Bounds) of *U*&#8217;s lower bound;
* and *T*&#8217;s upper bound is a [sub-bound](#sec-Upper-Bounds) of *U*&#8217;s upper bound.

### Lower Bounds

A lower bound *B* is a sub-bound of lower bound *C* if:

* *C* is unconstrained;
* or both lower bounds are inclusive and *B* >= *C*;
* or both lower bounds are exclusive and *B* >= *C*;
* or *B* is inclusive, *C* is exclusive and *B* > *C*;
* or *B* is exclusive, *C* is inclusive and:
  * Both bounds are `number`s and *B* >= *C*;
  * or both bounds are `integer`s and *B* >= *C* - 1;
  * or both bounds are `int32`s and *C* is greater than the minimum representable number (-2147483648) and *B* >= *C* - 1;
  * or both bounds are `int32`s and *C* is equal to the minimum representable number (-2147483648) and *B* >= *C*.

TODO float-valued bounds

TODO promotion rules for combinations of `integer`, `number`, `int32` and float bounds

### Upper Bounds

An upper bound *B* is a sub-bound of upper bound *C* if:

* *C* is unconstrained;
* or both upper bounds are inclusive and *B* <= *C*;
* or both upper bounds are exclusive and *B* <= *C*;
* or *B* is inclusive, *C* is exclusive and *B* < *C*;
* or *B* is exclusive, *C* is inclusive and:
  * Both bounds are `number`s and *B* <= *C*;
  * or both bounds are `integer`s and *B* <= *C* + 1;
  * or both bounds are `in32`s and *C* is less than the maximum representable number (2147483647) and *B* <= *C* + 1;
  * or both bounds are `int32`s and *C* is equal to the maximum representable number (2147483647) and *B* <= *C*.

TODO float bounds

TODO promotion rules for combinations of `integer`, `number`, `int32` and float bounds

## Unions

UnionCommutativity ::: T | U = U | T

UnionAssociativity ::: T | ( U | V ) = ( U | V ) | T

TODO regex subtyping rule, is there a more formal name for this?
Simplification: if T is a subtype of U, then T | U is the same type as U.

TODO Subtypes: T <: T | U, U <: T | U.

TODO Supertypes: if both T and U are subtypes of V, then T | U is also a subtype of V.

TODO T | U <: V | X

TODO T | U <: V & X