<?php
/*
   Copyright 2007, 2008 Nicolás Gudiño
   This file is part of Asternic Call Center Stats.
    Asternic Call Center Stats is free software: you can redistribute it
    and/or modify it under the terms of the GNU General Public License as
    published by the Free Software Foundation, either version 3 of the
    License, or (at your option) any later version.
    Asternic Call Center Stats is distributed in the hope that it will be
    useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
    You should have received a copy of the GNU General Public License
    along with Asternic Call Center Stats.  If not, see
    <http://www.gnu.org/licenses/>.
*/

require_once("dblib.php");
require_once("misc.php");
$queue_log_dir  = '/var/log/asterisk/';
$queue_log_file = 'queue_log';

$dbhost = 'mysql.host.remote';
$dbname = 'qstats';
$dbuser = 'qstats';
$dbpass = 'qstats';

$midb = conecta_db($dbhost,$dbname,$dbuser,$dbpass);
$self = $_SERVER['PHP_SELF'];

$DB_DEBUG = false;

?>
