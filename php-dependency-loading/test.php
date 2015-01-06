<?php

//set up the autoloader
require_once('Vendor/SplClassLoader.php');
$classLoader = new SplClassLoader('MyNS', '.');
$classLoader->register();


$factory = new MyNS\Factory();

$classB = $factory->load('MyNS\ClassB');

echo $classB->doSomething();


//in a unit testing flow

$classBTest = new MyNS\ClassB(array(
    'depA' => 'someMock',
    'depB' => 'someMock'
));
