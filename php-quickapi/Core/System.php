<?php

namespace QuickAPI\Core;
use QuickAPI\Core as Core;

class System {

    private $provider;

    public function __construct($provider) {
        $this->provider = $provider;
    }

    public function login() {

    }

    public function logout() {

    }

    /*user*/

    public function registerUser(Core\Directive $directive) {

        $data = new Core\SystemData();
        $pars = $directive->getParameters();

        if (!$this->provider->checkUser($pars['email'])) {

            $password = password_hash($pars['password'], PASSWORD_DEFAULT);

            $userId = $this->provider->createUser(array('email'=>$pars['email'], 'password'=>$password));

            $userData = $this->provider->getUser($userId)[0];

            $user = new Core\User();

            $user->setData($userData);

            $directive->getSession()->setUser($user);

            $data->setData(array(
                'user' => $user->output()
            ));

        } else {

            //must already exist; log them in

            $user = $this->provider->getUserByEmail($pars['email'])[0];

            if (!empty($user)) {

                $userObj = new Core\User($user);

                if (password_verify($pars['password'], $user['password'])) {

                    $directive->getSession()->setUser($userObj);

                } else {
                    $data->addError('badpassass');
                }

            } else {
                $data->addError('whoops');
            }

        }

        return $data;

    }

    public function checkUser(Core\Directive $directive) {

        $data = new Core\SystemData();
        $pars = $directive->getParameters();

        $userCheck = $this->provider->checkUser($pars['email']);

        $data->setData(array(
            'isUser' => $userCheck
        ));

        return $data;

    }

    /*end user*/

    public function refresh(Core\Directive $directive) {

        $data = new Core\SystemData();

        //just check for current session and associated app state
        $session = $directive->getSession();

        if ($session->isAuthenticated()) {

            $data->setData(array(
                'user' => $session->getUser(),
                'organization' => $session->getOrganization(),
                'state' => $session->getState()
            ));

        } else {

            $data->setData(array(
                'state' => array()
            ));

        }

        return $data;

    }

}