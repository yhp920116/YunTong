-- sqlite3 DataBase.db && .read ./DataBase.sql

--					--
-- Database Version: Must be synchronized with 'kDataBaseVersion' from NgnDataBaseService
-- off course we can change this value from objective-c but it will be too easy for you.
-- To be honest, it is done like this to force you to only change 'kDataBaseVersion' if required :)
-- See also '-databaseVersion' from INgnStorageService
--					--
PRAGMA user_version = 0;

--					--
-- Application Info --
--					--
CREATE TABLE app_info(
	id INTEGER PRIMARY KEY,
	softVersion INTEGER,
	databaseVersion INTEGER 
);

--			--
--	History --
--			--

CREATE TABLE hist_event( 
	id INTEGER PRIMARY KEY, 
	seen TINYINT(1),
	status TINYINT(8),
	mediaType TINYINT(8),
	remoteParty TEXT,
	start DOUBLE,
	end DOUBLE,
	content BLOB
);

--			--
--	Favorites --
--			--

CREATE TABLE favorites( 
	id INTEGER PRIMARY KEY, 
	number TEXT,
	mediaType TINYINT(8)
);

--			     --
--	WeiCallUsers --
--			     --

CREATE TABLE weicallusers(
	id INTEGER PRIMARY KEY,
	phonenumber TEXT,
	mynumber TEXT
);

--			     --
--	System_Notification  --
--			     --

CREATE TABLE system_notification(
	id INTEGER PRIMARY KEY,
	mynumber TEXT,
	content TEXT,
	receivetime DOUBLE,
	read TINYINT(1)
);

--			     --
--	IAP_Records  --
--			     --

CREATE TABLE iap_records(
	id INTEGER PRIMARY KEY,
	mynumber TEXT,
	purchasedid TEXT,
	productid TEXT,
	time DOUBLE,
       purchasedreceipt Text
);

--			     --
--	Conf_Favorites_Name --
--			     --

CREATE TABLE conf_favorites_name(
	id INTEGER PRIMARY KEY,
	mynumber TEXT,
	name TEXT,
	uuid TEXT
);

--			      --
--	Conf_Favorites_Number --
--			      --

CREATE TABLE conf_favorites_number(
	id INTEGER PRIMARY KEY,
	phonenumber TEXT,
	uuid TEXT
);