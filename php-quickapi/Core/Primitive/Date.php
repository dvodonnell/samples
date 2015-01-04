<?php

namespace QuickAPI\Core\Primitive;
use QuickAPI\Core as Core;

class Date extends Core\Primitive {

    private $dateTime = false;

    public function __construct($val){
        if (is_integer($val)) {
            $this->dateTime = new \DateTime();
            $this->dateTime->setTimestamp($val);
        }
    }

    public function output() {
        return $this->dateTime->format('Y-m-d H:i:s');
    }

}

