<?php

namespace QuickAPI\Core\Provider;
use QuickAPI\Core as Core;
use QuickAPI\Core\Provider\MySQL as MySQLNS;

class MySQL implements Core\CoreInterface\Provider {

    private $db = null;

    public function __construct(){

    }

    public function connect($config) {

        $this->db = new MySQLNS\MysqliDb(
            $config['host'],
            $config['username'],
            $config['password'],
            $config['schema']
        );

    }

    public function find($directive) {

        $tablePrefix = 'entity';

        $tables = explode(NAMESPACE_SEPARATOR, $directive->getContentTypeId());
        $tables = array_map('strtolower', $tables);

        $maintable = array_pop($tables);

        $queryPars = array(
            'selects' => array(
                'entity.permission',
                'entity.user'
            ),
            'joins' => array(
                'JOIN entity ON entity.id = '.$maintable.'.entity'
            ),
            'wheres' => array(
                'entity.enabled = 1'
            ),
            'values' => array()
        );

        $mainTableDef = $directive->getContentType($maintable);

        foreach ($mainTableDef['attributes'] as $attribId=>$attribute) {
            $queryPars['selects'][] = $maintable . '.' . $attribute['column'] . ' as '.$attribId;
        }

        $currentPrefix = $tablePrefix;

        foreach ($tables as $table) {

            $tableDef = $directive->getContentType($table);
            $currentPrefix = $currentPrefix . '_' . $table;

            foreach ($tableDef['attributes'] as $attribId=>$attribute) {
                $queryPars['selects'][] = $table . '.' . $attribute['column'] . ' as '.$attribId;
            }

            $queryPars['joins'][] = 'JOIN '.$currentPrefix.' as '.$table.' ON entity.id = '.$table.'.entity';

        }

        $sql = "SELECT ";
        $sql .= implode(',', $queryPars['selects']);
        $sql .= ' FROM '.$currentPrefix . '_' .$maintable . ' as '.$maintable . ' ';
        $sql .= implode(' ', $queryPars['joins']);

        $result = $this->db->rawQuery($sql);

        return $result;

    }

    public function get(){

    }

    public function save(){

    }

    public function remove(){

    }

    /*system*/

    public function createOrg($data) {

        $this->db->insert('organization', $data);
        return $this->db->getInsertId();

    }

    public function createUser($data) {

        $this->db->insert('user', $data);
        return $this->db->getInsertId();

    }

    public function createMembership($data) {
        $this->db->insert('membership', $data);
        return $this->db->getInsertId();
    }

    public function checkUser($email) {

        $sql = "
            SELECT id FROM user WHERE email = ?
        ";

        $result = $this->db->rawQuery($sql, array($email));

        return (!empty($result));

    }

    public function getOrg($id) {

        $sql = "

        SELECT organization.* FROM organization
        LEFT JOIN entity_region ON entity_region.entity = organization.region
        LEFT JOIN entity_industry ON entity_industry.entity = organization.industry
        WHERE organization.id = ?

        ";

        return $this->db->rawQuery($sql, array($id));

    }

    public function getUser($id) {

        $sql = "

        SELECT user.* FROM user
        LEFT JOIN entity_person ON entity_person.entity = user.person
        WHERE user.id = ?

        ";

        return $this->db->rawQuery($sql, array($id));

    }

    public function getUserByEmail($email) {

        $sql = "

        SELECT user.* FROM user
        LEFT JOIN entity_person ON entity_person.entity = user.person
        WHERE user.email = ?

        ";

        return $this->db->rawQuery($sql, array($email));

    }

    /*tools*/


}

