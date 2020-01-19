package jsontypes.common;

class Pair<T, U> {
    public final first: T;
    public final second: U;

    public inline function new(first: T, second: U) {
        this.first = first;
        this.second = second;
    }
}