package hxcheck;

import haxe.ds.Option;
import Std.random;

class Gen<T> {

    public final generate: Void -> T;

    public function new(generate: Void -> T) {
        this.generate = generate;
    }

    public function map<U>(f: T -> U): Gen<U> {
        return new Gen<U>(() -> f(generate()));
    }

    public function flatMap<U>(f: T -> Gen<U>): Gen<U> {
        return new Gen<U>(() -> f(generate()).generate());
    }

    public function filter(predicate: T -> Bool, maxAttempts: Int = 100): Gen<T> {
        return new Gen<T>(() -> {
            var attempts = 0;
            while (attempts < maxAttempts) {
                final value = generate();
                if (predicate(value)) {
                    return value;
                } else {
                    attempts++;
                }
            }
            throw "Exceeded maximum number of attempts (" + maxAttempts + ")";
        });
    }

    public static function const<T>(value: T): Gen<T> {
        return new Gen<T>(() -> value);
    }

    public static function oneOf<T>(gens: Array<Gen<T>>): Gen<T> {
        if (gens.length == 0) throw "Empty array";
        return new Gen<T>(() -> gens[random(gens.length)].generate());
    }

    public static function choose<T>(values: Array<T>): Gen<T> {
        if (values.length == 0) throw "Empty array";
        return new Gen<T>(() -> values[random(values.length)]);
    }

    public static function maybe<T>(gen: Gen<T>): Gen<Option<T>> {
        return new Gen<Option<T>>(() -> if (random(2) == 0) None else Some(gen.generate()));
    }

    public static function arrayOf<T>(gen: Gen<T>, maxLength: Int = 100): Gen<Array<T>> {
        if (maxLength < 0) maxLength = 0;
        return nums(0, maxLength).flatMap(arrayOfN.bind(gen, _));
    }

    public static function nonEmptyArrayOf<T>(gen: Gen<T>, maxLength: Int = 100): Gen<Array<T>> {
        if (maxLength < 1) maxLength = 1;
        return nums(1, maxLength).flatMap(arrayOfN.bind(gen, _));
    }

    public static function arrayOfN<T>(gen: Gen<T>, length: Int): Gen<Array<T>> {
        if (length < 0) length = 0;
        return new Gen<Array<T>>(() -> {
            final values = [];
            for (i in 0...length) {
                values.push(gen.generate());
            }
            return values;
        });
    }

    public static function chars(from: String, to: String): Gen<String> {
        return nums(from.charCodeAt(0), to.charCodeAt(0)).map(String.fromCharCode.bind(_));
    }

    public static function nums(from: Int, to: Int): Gen<Int> {
        if (to < from) throw "Invalid range";
        final range = to - from;

        return new Gen<Int>(() -> random(range) + from);
    }
}
