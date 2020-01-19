package hxcheck;

class Props {
    public static function forAll<T>(gen: Gen<T>, block: T -> Void, checks: Int = 100) {
        for (i in 0...checks) {
            block(gen.generate());
        }
    }
}
