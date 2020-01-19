package jsontypes;

import utest.Runner;
import utest.ui.Report;

class AllTests {

    static public function main() {
        var runner = new Runner();

        runner.addCase(new jsontypes.parser.LexerTest());

        Report.create(runner);
        runner.run();
    }
}
