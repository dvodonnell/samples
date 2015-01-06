<?php

namespace MyNS;
use MyNS;

class ClassA extends MyNS\Base {

    public static $dependencies = array(
        'MyNS\DependencyA' => 'depA'
    );

}