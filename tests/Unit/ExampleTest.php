<?php declare(strict_types = 1);

namespace Skeleton\Tests\Unit;

use PHPUnit\Framework\TestCase;
use Skeleton\Skeleton;

class ExampleTest extends TestCase
{
    public function parameters()
    {
        return [
            [9, "yes"],
            [10, "no"],
            [11, "no"],
        ];
    }

    /**
     * @dataProvider parameters
     */
    public function test_this_is_a_sample_test($input, $expected)
    {
        // demonstrate mutation testing
        $example = new Skeleton();
        $this->assertEquals($expected, $example->example($input));
    }
}
