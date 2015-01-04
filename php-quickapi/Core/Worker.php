<?php

namespace QuickAPI\Core;
use QuickAPI\Core as Core;

class Worker {

    private $provider;

    public function __construct($provider) {
        $this->provider = $provider;
    }

    public function find($directive, $parameters = array()) {

        $results = $this->provider->find($directive);

        $collection = new Core\Collection();

        foreach ($results as $item) {
            $entity = new Core\Entity();
            $entity->setData($item);
            $collection->addEntity($entity);
        }

        return $collection;

    }

    public function get($directive, $parameters = array()) {

    }

    public function save($directive, $parameters = array()) {

    }

    public function remove($directive, $parameters = array()) {

    }

}