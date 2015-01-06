<?php

namespace MyNS;
use MyNS;

class Factory {

    public function load($className) {

        //load an instance of the class and inject all its loaded dependencies if available

        $newInstance = false;

        if (class_exists($className)) {

            $injectables = array();

            if (method_exists($className, 'buildDependencyArray')) {

                //fetch the dependencies statically
                $dependencies = $className::buildDependencyArray();

                foreach ($dependencies as $dependency => $alias) {

                    //could also do singletons here and have Factory store references
                    $injectables[$alias] = $this->load($dependency);

                }

            }

            if (!empty($injectables)) {
                $newInstance = new $className($injectables);
            } else {
                $newInstance = new $className();
            }

        }

        return $newInstance;

    }

}