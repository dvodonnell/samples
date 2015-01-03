<?php

namespace QuickAPI\Core;
use QuickAPI\Core as Core;

class Router {

    private $definition = array();

    public function __construct($definition = array()) {
        $this->definition = $definition;
    }

    public function route(Core\Directive $directive, $path, $request) {

        $path = ltrim($path, '/');
        $segments = explode('/', $path);
        $action = array_shift($segments);

        if (isset($this->definition['action'][$action])) {

            $actionDef = $this->definition['action'][$action];

            $directive->setActionId($action);
            $directive->setAction($actionDef);

            if (!isset($actionDef['systemTask']) || !$actionDef['systemTask']) {

                $directive->setContentTypeId(implode(NAMESPACE_SEPARATOR, array_map('ucfirst', $segments)));

                $i = count($segments);
                $contentDefs = $this->definition['contentTypes'];

                while ($i--) {
                    $item = array_shift($segments);
                    if (!$contentDefs || !isset($contentDefs[$item])) {
                        break;
                    }
                    $directive->addContentType($item, $contentDefs[$item]);
                    if ($i > 0) {
                        $contentDefs = (isset($contentDefs['subTypes'])) ? $contentDefs['subTypes'] : false;
                    }
                }

                if ($i != -1) {
                    $directive->setInvalid();
                }

            }

            if (!empty($request)) {
                $directive->setParameters($request);
            }

        }

        return $directive;

    }

}