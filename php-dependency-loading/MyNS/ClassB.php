<?php

namespace MyNS;
use MyNS;

class ClassB extends MyNS\ClassA {

    public static $dependencies = array(
        'MyNS\DependencyB' => 'depB'
    );

    public function doSomething() {
        return $this->getResource('depA')->foo();
    }

}