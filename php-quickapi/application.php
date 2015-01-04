<?php

namespace QuickAPI;
use QuickAPI\Core as Core;

class Application {

    private $configuration = array();

    private $assets = array(
        'provider' => null,
        'factory' => null,
        'router' => null,
        'buffer' => null,
        'session' => null
    );

    public function __construct($configuration = array()) {

        $this->configuration = $configuration;
        $this->massageConfig();
        $this->initialize();

    }

    private function initialize() {

        define('NAMESPACE_SEPARATOR', '\\');

        /* Autoloader */
        require_once($this->configuration->appPath . DIRECTORY_SEPARATOR . 'Core/Autoloader.php');
        $autoloader = new \SplClassLoader('QuickAPI', $this->configuration->appPath . DIRECTORY_SEPARATOR . '..');
        $autoloader->register();

        /* Router */
        $this->assets['router'] = new Core\Router($this->configuration->definition->get());

        /* Data Provider */
        $providerNS = 'QuickAPI\\Core\\Provider\\' . $this->configuration['provider'];
        $this->assets['provider'] = new $providerNS();
        $this->assets['provider']->connect($this->configuration['providerConfig']);

        /* Buffer */
        $this->assets['buffer'] = new Core\Buffer();

        /* Session */
        $this->assets['session'] = new Core\Session();

    }

    public function massageConfig() {

        $this->configuration['provider'] = (!empty($this->configuration['provider'])) ? $this->configuration['provider'] : 'MySQL';

    }

    public function run($path, $request) {

        $directive = new Core\Directive();
        $directive->setSession($this->assets['session']);

        $this->assets['router']->route($directive, $path, $request);

        if ($directive->isValid()) {

            if ($directive->isSystemTask()) {

                $worker = new Core\System($this->assets['provider']);

            } else {

                $worker = new Core\Worker($this->assets['provider']);

            }

            $actionId = $directive->getActionId();
            $data = $worker->$actionId($directive);
            $this->assets['buffer']->setData($data);

        }

    }

    public function dump() {

        return $this->assets['buffer']->output();

    }

}