<?php declare(strict_types = 1);

namespace Skeleton;

class Skeleton
{
    public function example(int $test): string
    {
        if ($test < 10) {
            return "yes";
        }

        return "no";
    }
}
