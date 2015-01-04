<?php

include_once './QuickAPI' . DIRECTORY_SEPARATOR . 'application.php';

//load app definition
$definition = json_decode(file_get_contents("definition.json"));

//instantiate app
$app = new \QuickAPI\Application(array(
    'appPath' => './QuickAPI',
    'provider' => 'MySQL',
    'providerConfig' => array(
        'host' => 'localhost',
        'username' => 'testUser',
        'password' => 'abc123',
        'schema' => 'testDb'
    ),
    'definition' => $definition
));

$app->run($_SERVER['PATH_INFO'], $_REQUEST);

$output = $app->dump();


header('Content-Type: application/json');
echo json_encode($output);
