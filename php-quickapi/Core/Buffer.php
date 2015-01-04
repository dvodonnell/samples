<?php

namespace QuickAPI\Core;

class Buffer {

    private $errors = array();
    private $data = array();

    public function __construct() {

    }

    public function addError($code, $msg, $type = 'minor') {
        $this->errors[$type][] = array(
            'code' => $code,
            'msg' => $msg
        );
    }

    public function setData($data) {
        $this->data = $data;
    }

    public function output() {

        $returnArr = array(
            'success' => (empty($this->errors['fatal'])),
            'data' => (!empty($this->data)) ? $this->data->output() : null
        );

        if (!empty($this->errors)) {
            $returnArr['errors'] = $this->errors;
        }

        return $returnArr;

    }

}