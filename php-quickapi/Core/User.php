<?php

namespace QuickAPI\Core;
use QuickAPI\Core as Core;

class User implements Core\CoreInterface\SystemEntity {

    public $id;
    private $attributes = array();
    private $memberships = array();

    public function __construct($data = array()){
        if (!empty($data)) {
            $this->setData($data);
        }
    }

    public function setData($data){
        $this->attributes['email'] = $data['email'];
        $this->id = $data['id'];
    }

    public function output(){
        return array(
            'id' => $this->id,
            'email' => $this->attributes['email'],
            'memberships' => $this->outputMemberships()
        );
    }

    public function addMembership($membership) {
        $this->memberships[] = $membership;
    }

    public function outputMemberships() {
        $data = array();
        foreach ($this->memberships as $membership) {
            $data[] = $membership->output();
        }
        return $data;
    }

}

