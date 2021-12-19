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

    # Database settings
    $dbEngine = getenv('DB_ENGINE') ?: 'pdo_mysql';
    $dbHost = getenv('DB_HOST') ?: 'mysql'; 
    $dbPort = getenv('DB_PORT') ?: '3306';
    $dbName = getenv('DB_DATABASE') ?: 'spotweb';
    $dbUser = getenv('DB_USER') ?: 'spotweb';
    $dbPass = getenv('DB_PASSWORD') ?: 'spotweb';

    # Spotweb settings
    $spotwebSettings['systemtype'] = getenv("SPOTWEB_SYSTEMTYPE") ?: 'public';
    $spotwebSettings['username'] = getenv("SPOTWEB_USERNAME") ?: 'joachim';
    $spotwebSettings['newpassword1'] = getenv("SPOTWEB_PASSWORD") ?: 'demo123';
    $spotwebSettings['newpassword2'] = getenv("SPOTWEB_PASSWORD") ?: 'demo123';
    $spotwebSettings['firstname'] = getenv("SPOTWEB_FIRSTNAME") ?: 'demo';
    $spotwebSettings['lastname'] = getenv("SPOTWEB_LASTNAME") ?: 'spotweb';
    $spotwebSettings['mail'] = getenv("SPOTWEB_MAIL") ?: 'joachim@spotweb.com';
    $spotwebSettings['userid'] = -1;

    echo 'Connecting to [engine: '. $dbEngine.'][host: '. $dbHost.'][port:'.$dbPort.'][database: '.$dbName.']'.PHP_EOL;

    $bootstrap = new Bootstrap();
    $dbCon = dbeng_abs::getDbFactory($dbEngine);
    $dbCon->connect(
        $dbHost,
        $dbUser,
        $dbPass,
        $dbName,
        $dbPort,
        'public'
    );

    echo 'Connected to DB'.PHP_EOL;

    $daoFactory = Dao_Factory::getDAOFactory($dbEngine);
    $daoFactory->setConnection($dbCon);
    $svcUserRecord = new ServicesValidateUserRecord(
        $daoFactory,
        $bootstrap->getSettings($daoFactory, false)
    );

    $errorList = $svcUserRecord->validateUserRecord($spotwebSettings, false)->getErrors();

    if (!empty($errorList)) {
        throw new Exception($errorList[0]);
    }

    echo 'Validated user settings.'.PHP_EOL;

} catch (Exception $x) {
    echo PHP_EOL.PHP_EOL;
    echo 'SpotWeb crashed'.PHP_EOL.PHP_EOL;
    echo 'Initializing database schema or settings failed:'.PHP_EOL;
    echo '   '.$x->getMessage().PHP_EOL;
    echo PHP_EOL.PHP_EOL;
    echo $x->getTraceAsString();
    exit(1);
} // catch