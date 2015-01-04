<?php

namespace QuickAPI\Core;
use QuickAPI\Core as Core;

class SystemData implements Core\CoreInterface\Data {

    private $data = null;
    private $errors = array();

    public function __construct(){

    }

    public function addError($err){
        $this->errors[] = $err;
    }

    public function setData($data) {
        $this->data = $data;
    }

    public function output() {
        $data = array();
        foreach ($this->data as $k=>$obj) {
            if (method_exists($obj, 'output')) {
                $data[$k] = $obj->output();
            } else {
                $data[$k] = $obj;
            }
        }
        return $data;
    }

}

