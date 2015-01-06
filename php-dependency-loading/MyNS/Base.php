<?php

namespace MyNS;

class Base {

    public $injectedDependencies;

    public function __construct($dependencies = array()) {
        $this->injectedDependencies = $dependencies;
    }

    public static function buildDependencyArray() {

        //loop through the static-declared dependencies in all the children

        $dependencies = array();

        $className = get_called_class();

        //add the currently called class to the stack
        $parentClasses = class_parents($className) + array($className => $className);

        foreach ($parentClasses as $parentClass) {

            if (class_exists($parentClass, false) && property_exists($parentClass, 'dependencies')) {

                $classDependencies = $parentClass::$dependencies;

                if (is_array($classDependencies)) {
                    $dependencies = $dependencies + $classDependencies;
                }

            }

        }

        return $dependencies;

    }

    public function getResource($key) {
        return (isset($this->injectedDependencies[$key])) ? $this->injectedDependencies[$key] : false;
    }

}