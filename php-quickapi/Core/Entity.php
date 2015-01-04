<?php

namespace QuickAPI\Core;
use QuickAPI\Core as Core;

class Entity implements Core\CoreInterface\Data {

    private $attributes = array();

    public function __construct($dataArr = array()){
        $this->setData($dataArr);
    }

    public function setData($dataArr) {
        foreach ($dataArr as $k=>$v) {
            $this->attributes[$k] = $v;
        }
    }

    public function output() {
        return $this->attributes;
    }

}

