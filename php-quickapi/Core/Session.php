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
        $this->loadClient();

    }

    public function getLocale() {
        return $_SESSION[SESSION_NAMESPACE]['locale'] || 1;
    }

    public function setUser($user) {
        $_SESSION[SESSION_NAMESPACE]['user'] = $user->output();
        $this->user = $user;
    }

    public function setOrganization($org) {
        $_SESSION[SESSION_NAMESPACE]['organization'] = $org->output();
        $this->organization = $org;
    }

    public function loadUser() {
        $this->user = new Core\User($_SESSION[SESSION_NAMESPACE]['user']);
    }

    public function loadOrganization() {
        $this->organization = new Core\Organization($_SESSION[SESSION_NAMESPACE]['organization']);
    }

    public function getUser() {
        return (isset($this->user) ? $this->user : false);
    }

    public function getOrganization() {
        return (isset($this->organization) ? $this->organization : false);
    }

    public function getState() {
        return array();
    }

}