<?php

namespace QuickAPI\Core\CoreInterface;

interface Provider {

    public function find($directive);

    public function get();

    public function save();

    public function remove();

    public function checkUser($email);

}