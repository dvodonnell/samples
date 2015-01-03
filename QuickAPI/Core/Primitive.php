<?php

namespace QuickAPI\Core;
use QuickAPI\Core as Core;

class Primitive implements Core\CoreInterface\Data {

    private $attributes = array();

    public function __construct(){

    }

    public function output() {
        return $this->attributes;
    }

}

