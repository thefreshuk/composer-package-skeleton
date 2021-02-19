<?php declare(strict_types = 1);

namespace Skeleton\Tests\Performance;

use Skeleton\Skeleton;

class ExampleBench
{
    public function bench_example()
    {
        $example = new Skeleton();
        $example->example(rand(0, 20));
    }
}
