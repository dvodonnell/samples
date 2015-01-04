<?php

namespace QuickAPI\Core;
use QuickAPI\Core as Core;

Class Session {

    private $factory = null;
    private $locale = null;
    private $user = null;
    private $organization = null;

    public function __construct() {

        session_start();

        if ($this->isAuthenticated()) {
            $this->loadUser();
            $this->loadOrganization();
        }

    }

    public function isAuthenticated() {

        return (isset($_SESSION[SESSION_NAMESPACE]) && $_SESSION[SESSION_NAMESPACE]['user']);

    }

    public function deAuthenticate() {

        unset($_SESSION[SESSION_NAMESPACE]);

    }

    public function authenticate($email, $password) {

        $this->loadUser();

    }

    public function getLocale() {
        return $_SESSION[SESSION_NAMESPACE]['locale'] || 1;
    }

    public function setUser($user) {
        $_SESSION[SESSION_NAMESPACE]['user'] = $user->output();
        $this->user = $user;
    }

    public function loadUser() {
        $this->user = new Core\User($_SESSION[SESSION_NAMESPACE]['user']);
    }

    public function getUser() {
        return (isset($this->user) ? $this->user : false);
    }

    public function getState() {
        return array();
    }

}