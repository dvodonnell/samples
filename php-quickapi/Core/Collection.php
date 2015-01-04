<?php

namespace QuickAPI\Core;
use QuickAPI\Core as Core;

class Collection implements Core\CoreInterface\Data {

    private $entities = array();

    public function __construct(){

    }

    public function addEntity(Core\Entity $entity) {
        $this->entities[] = $entity;
    }

    public function output() {
        $outputArr = array();
        foreach ($this->entities as $entity) {
            $outputArr[] = $entity->output();
        }
        return $outputArr;
    }

}

