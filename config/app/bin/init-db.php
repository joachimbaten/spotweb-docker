#!/usr/bin/php
<?php
error_reporting(2147483647);


try {
    require_once __DIR__.'/../vendor/autoload.php';

    /*
     * Make sure we are not run from the server, an db init can take too much time and
     * will easily be aborted by either a database, apache or browser timeout
     */
    if (!SpotCommandline::isCommandline()) {
        exit('init-db.php can only be run from the console, it cannot be run from the web browser');
    } // if

    // Database settings
    $dbSettings['engine'] = getenv('DB_ENGINE') ?: 'pdo_mysql';
    $dbSettings['host'] = getenv('DB_HOST') ?: 'mysql'; 
    $dbSettings['port'] = getenv('DB_PORT') ?: '3306';
    $dbSettings['dbname'] = getenv('DB_DATABASE') ?: 'spotweb';
    $dbSettings['user'] = getenv('DB_USER') ?: 'spotweb';
    $dbSettings['pass'] = getenv('DB_PASSWORD') ?: 'spotweb';
    $dbSettings['schema'] = 'public';

    // Spotweb user settings
    $spotUser['systemtype'] = getenv("SPOTWEB_SYSTEMTYPE") ?: 'public';
    $spotUser['username'] = getenv("SPOTWEB_USERNAME") ?: 'myawesomeuser';
    $spotUser['newpassword1'] = getenv("SPOTWEB_PASSWORD") ?: 'demo123';
    $spotUser['newpassword2'] = getenv("SPOTWEB_PASSWORD") ?: 'demo123';
    $spotUser['firstname'] = getenv("SPOTWEB_FIRSTNAME") ?: 'demo';
    $spotUser['lastname'] = getenv("SPOTWEB_LASTNAME") ?: 'spotweb';
    $spotUser['mail'] = getenv("SPOTWEB_MAIL") ?: 'demo@spotweb.com';
    $spotUser['userid'] = -1;

    echo 'Connecting to [engine: '. $dbSettings['engine'].'][host: '. $dbSettings['host'].'][port:'.$dbSettings['port'].'][database: '.$dbSettings['dbname'].']'.PHP_EOL;

    // Init the data access objects
    $bootstrap = new Bootstrap();
    $dbCon = dbeng_abs::getDbFactory($dbSettings['engine']);
    $dbCon->connect(
        $dbSettings['host'],
        $dbSettings['user'],
        $dbSettings['pass'],
        $dbSettings['dbname'],
        $dbSettings['port'],
        $dbSettings['schema']
    );
    
    $daoFactory = Dao_Factory::getDAOFactory($dbSettings['engine']);
    $daoFactory->setConnection($dbCon);

    echo 'Connected to DB'.PHP_EOL;

    // First validate the provided user
    echo 'Validating user [username: '.$spotUser['username'].']'.PHP_EOL;
    $svcValidateUserRecord = new ServicesValidateUserRecord(
        $daoFactory,
        $bootstrap->getSettings($daoFactory, false)
    );

    $errorList = $svcValidateUserRecord->validateUserRecord($spotUser, false)->getErrors();

    if (!empty($errorList)) {
        throw new Exception($errorList[0]);
    }

    // Create the database structure
    echo 'Creating database structure'.PHP_EOL;

    $dbStruct = SpotStruct_abs::factory($dbSettings['engine'], $daoFactory->getConnection());
    $dbStruct->updateSchema();

    // Create default settings and users
    echo 'Creating default settings & users'.PHP_EOL;

    $spotSettings = $bootstrap->getSettings($daoFactory, false);
    $svcUpgradeBase = new Services_Upgrade_Base($daoFactory, $spotSettings, $dbSettings['engine']);    
    $svcUpgradeBase->settings();
    $svcUpgradeBase->users();

    // Create/Update supplied settings and user
    echo 'Configuring system based on supplied information'.PHP_EOL;
    $svcUserRecord = new Services_User_Record($daoFactory, $spotSettings);
    $spotUser['userid'] = $svcUserRecord->createUserRecord($spotUser)->getData('userid');
    $svcUserRecord->setUserPassword($spotUser);
    // Change the administrators' account password to that of this created user.
    $adminUser = $svcUserRecord->getUser(SPOTWEB_ADMIN_USERID);
    $adminUser['newpassword1'] = $spotUser['newpassword1'];
    $svcUserRecord->setUserPassword($adminUser);
    // Update the settings with our system type and our admin id.
    $spotSettings->set('custom_admin_userid', $spotUser['userid']);
    $spotSettings->set('systemtype', $spotUser['systemtype']);
    // Set the system type.
    $svcUpgradeBase->resetSystemType($spotUser['systemtype']);

} catch (Exception $x) {
    echo PHP_EOL.PHP_EOL;
    echo 'SpotWeb crashed'.PHP_EOL.PHP_EOL;
    echo 'Initializing database schema or settings failed:'.PHP_EOL;
    echo '   '.$x->getMessage().PHP_EOL;
    echo PHP_EOL.PHP_EOL;
    echo $x->getTraceAsString();
    exit(1);
} // catch