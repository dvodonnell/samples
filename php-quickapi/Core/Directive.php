<?php

namespace QuickAPI\Core;
use QuickAPI\Core;

class Directive {

    private $action = null;
    private $actionId = null;
    private $contentTypes = array();
    private $parameters = null;
    private $contentTypeId = null;
    private $session = null;

    private $valid = true;

    public function __construct() {

    }

    public function setAction($actionDef) {
        $this->action = $actionDef;
    }

    public function setActionId($actionId) {
        $this->actionId = $actionId;
    }

    public function addContentType($contentId, $contentTypeDef) {
        $this->contentTypes[$contentId] = $contentTypeDef;
    }

    public function setContentTypeId($contentTypeId) {
        $this->contentTypeId = $contentTypeId;
    }

    public function setParameters($pars) {
        $this->parameters = $pars;
    }

    public function setInvalid() {
        $this->valid = false;
    }

    public function setSession(Core\Session $session) {
        $this->session = $session;
    }

    public function getAction() {
        return (!is_null($this->action)) ? $this->action : false;
    }

    public function getActionId() {
        return (!is_null($this->actionId)) ? $this->actionId : false;
    }

    public function getContentTypes() {
        return (!empty($this->contentTypes)) ? $this->contentTypes : false;
    }

    public function getContentType($id) {
        return (isset($this->contentTypes[$id])) ? $this->contentTypes[$id] : false;
    }

    public function getContentTypeId() {
        return (!is_null($this->contentTypeId)) ? $this->contentTypeId : false;
    }

    public function getParameters() {
        return (!is_null($this->parameters)) ? $this->parameters : false;
    }

    public function getSession() {
        return (!is_null($this->session)) ? $this->session : false;
    }

    public function isSystemTask() {
        $action = $this->getAction();
        return ($action && isset($action['systemTask']) && $action['systemTask']);
    }

    public function isValid() {
        return $this->valid;
    }

}