<?php

namespace QuickAPI\Core;
use QuickAPI\Core as Core;

class Membership {

    private $user;
    private $organization;
    private $role;

    public function __construct($data = array()){
        $this->setData($data);
    }

    public function setData($arr){
        $this->user = $arr['user'];
        $this->organization = $arr['organization'];
        $this->role = $arr['role'];
    }

    public function output() {
        return array(
            'user' => $this->user->output(),
            'organization' => $this->organization->output()
        );
    }

}

