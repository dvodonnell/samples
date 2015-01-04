<?php

namespace QuickAPI\Core;
use QuickAPI\Core as Core;

class Organization implements Core\CoreInterface\SystemEntity {

    private $name;
    private $region;
    private $industry;
    public $id;

    public function __construct($data = array()){
        $this->setData($data);
    }

    public function setData($arr){
        $this->name = $arr['name'];
        $this->region = $arr['region'];
        $this->industry = $arr['industry'];
        $this->id = $arr['id'];
    }

    public function output(){
        return array(
            'id' => $this->id,
            'name' => $this->name,
            'region' => ($this->region instanceof Core\Entity) ? $this->region->output() : null,
            'industry' => ($this->industry instanceof Core\Entity) ? $this->industry->output() : null
        );
    }

}

