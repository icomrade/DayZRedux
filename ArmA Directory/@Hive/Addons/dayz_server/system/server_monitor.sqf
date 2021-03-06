[]execVM "\z\addons\dayz_server\system\s_fps.sqf"; //server monitor FPS (writes each ~181s diag_fps+181s diag_fpsmin*)

dayz_versionNo = 		getText(configFile >> "CfgMods" >> "DayZ" >> "version");
dayz_hiveVersionNo = 	getNumber(configFile >> "CfgMods" >> "DayZ" >> "hiveVersion");
private ["_random","_date","_year","_month","_day","_hour","_minute","_result","_status","_val","_pos","_wsDone","_dir","_objectPos","_block","_isOK","_countr","_objWpnTypes","_objWpnQty","_dam","_selection","_object","_idKey","_type","_ownerID","_worldspace","_intentory","_hitPoints","_fuel","_damage","_position","_noTilt","_config","_locName","_buildingList","_id","_script","_key","_outcome","_myArray","_cfgLocations"];
_script = getText(missionConfigFile >> "onPauseScript");

if ((count playableUnits == 0) and !isDedicated) then {
	isSinglePlayer = true;
};

waitUntil{initialized}; //means all the functions are now defined

diag_log "HIVE: Starting";

//Set the Time
	//Send request
	_key = "CHILD:307:";
	_result = _key call server_hiveReadWrite;
	_outcome = _result select 0;
	if (_outcome == "PASS") then {
		_date = _result select 1;
		
		//date setup
		_year = _date select 0;
		_month = _date select 1;
		_day = _date select 2;
		_hour = _date select 3;
		_minute = _date select 4;
		
		//Force full moon nights
		_date = [2012,6,6,_hour,_minute];
		
		if (isDedicated) then {
			//["dayzSetDate",_date] call broadcastRpcCallAll;
			setDate _date;
			dayzSetDate = _date;
			publicVariable "dayzSetDate";
		};
		diag_log ("HIVE: Local Time set to " + str(_date));
	};

	if (_script != "") then
	{
		diag_log "MISSION: File Updated";
	} else {
		diag_log "MISSION: File Needs Updating";
	};

	//Stream in objects
	/* STREAM OBJECTS */
		//Send the key
		_key = format["CHILD:302:%1:",dayZ_instance];
		_result = _key call server_hiveReadWrite;

		diag_log "HIVE: Request sent";
		
		//Process result
		_status = _result select 0;
		
		_myArray = [];
		if (_status == "ObjectStreamStart") then {
			_val = _result select 1;
			//Stream Objects
			diag_log ("HIVE: Commence Object Streaming...");
			for "_i" from 1 to _val do {
				_result = _key call server_hiveReadWrite;

				_status = _result select 0;
				_myArray set [count _myArray,_result];
				//diag_log ("HIVE: Loop ");
			};
			//diag_log ("HIVE: Streamed " + str(_val) + " objects");
		};
	
		_countr = 0;		
		{
				
			//Parse Array
			_countr = _countr + 1;
		
			_idKey = 	_x select 1;
			_type =		_x select 2;
			_ownerID = 	_x select 3;
			_worldspace = _x select 4;
			_intentory=	_x select 5;
			_hitPoints=	_x select 6;
			_fuel =		_x select 7;
			_damage = 	_x select 8;

			_dir = 0;
			_pos = [0,0,0];
			_wsDone = false;
			if (count _worldspace >= 2) then
			{
				_dir = _worldspace select 0;
				if (count (_worldspace select 1) == 3) then {
					_pos = _worldspace select 1;
					_wsDone = true;
				}
			};			
			if (!_wsDone) then {
				if (count _worldspace >= 1) then { _dir = _worldspace select 0; };
				_objectPos = [_worldspace select 1 select 0,_worldspace select 1 select 1,0];		
				_pos = [(_objectPos),0,15,1,0,2000,0,[],[_objectPos,[]]] call BIS_fnc_findSafePos;
				if (count _pos < 3) then { _pos = [_pos select 0,_pos select 1,0]; };
				diag_log ("MOVED OBJ: " + str(_idKey) + " of class " + _type + " to pos: " + str(_pos));
			};
		
			if (_damage < 1) then {
				diag_log format["OBJ: %1 - %2", _idKey,_type];
				
				//Create it
				_object = createVehicle [_type, _pos, [], 0, "CAN_COLLIDE"];
				_object setVariable ["lastUpdate",time];
				_object setVariable ["ObjectID", _idKey, true];
				_object setVariable ["CharacterID", _ownerID, true];

		if (_object isKindOf "AllVehicles") then {
			_object addEventHandler ["HandleDamage", { _this call vehicle_handleDamage }];
			_object addEventHandler ["GetOut", { _this call vehicle_handleInteract }];
			_object addEventHandler ["GetIn", { _this call vehicle_handleInteract }];
			_object addEventHandler ["Killed", { _this call vehicle_handleKilled }];
		};
				
				clearWeaponCargoGlobal  _object;
				clearMagazineCargoGlobal  _object;
				
		if ((_object isKindOf "Land_Cont_RX") or (_object isKindOf "Land_Cont2_RX")) then {
					_pos set [2,0];
					_object setpos _pos;
					_object addMPEventHandler ["MPKilled",{_this call vehicle_handleServerKilled;}];
				};
				_object setdir _dir;
				_object setDamage _damage;

		// Temporary removal of Huey ammo
		if (_object isKindOf "HH_RX") then {
			_object removeMagazineTurret ["100Rnd_762x51_M240",[0]];
			_object removeMagazineTurret ["100Rnd_762x51_M240",[0]];
			_object removeMagazineTurret ["100Rnd_762x51_M240",[1]];
			_object removeMagazineTurret ["100Rnd_762x51_M240",[1]];
		};

				if (count _intentory > 0) then {
					//Add weapons
					_objWpnTypes = (_intentory select 0) select 0;
					_objWpnQty = (_intentory select 0) select 1;
					_countr = 0;					
					{
						if (_x == "Crossbow") then { _x = "Crossbow_DZ" }; // Convert Crossbow to Crossbow_DZ
						_isOK = 	isClass(configFile >> "CfgWeapons" >> _x);
						if (_isOK) then {
							_block = 	getNumber(configFile >> "CfgWeapons" >> _x >> "stopThis") == 1;
							if (!_block) then {
								_object addWeaponCargoGlobal [_x,(_objWpnQty select _countr)];
							};
						};
						_countr = _countr + 1;
					} forEach _objWpnTypes; 
					
					//Add Magazines
					_objWpnTypes = (_intentory select 1) select 0;
					_objWpnQty = (_intentory select 1) select 1;
					_countr = 0;
					{
						if (_x == "BoltSteel") then { _x = "WoodenArrow" }; // Convert BoltSteel to WoodenArrow
						_isOK = 	isClass(configFile >> "CfgMagazines" >> _x);
						if (_isOK) then {
							_block = 	getNumber(configFile >> "CfgMagazines" >> _x >> "stopThis") == 1;
							if (!_block) then {
								_object addMagazineCargoGlobal [_x,(_objWpnQty select _countr)];
							};
						};
						_countr = _countr + 1;
					} forEach _objWpnTypes;

					//Add Backpacks
					_objWpnTypes = (_intentory select 2) select 0;
					_objWpnQty = (_intentory select 2) select 1;
					_countr = 0;
					{
						_isOK = 	isClass(configFile >> "CfgVehicles" >> _x);
						if (_isOK) then {
							_block = 	getNumber(configFile >> "CfgVehicles" >> _x >> "stopThis") == 1;
							if (!_block) then {
								_object addBackpackCargoGlobal [_x,(_objWpnQty select _countr)];
							};
						};
						_countr = _countr + 1;
					} forEach _objWpnTypes;
				};	
				
				if (_object isKindOf "AllVehicles") then {
					{
						_selection = _x select 0;
						if (!isNil "_selection") then {
						_dam = _x select 1;
							if (_object isKindOf "Air") then {
								//Skip these parts to make helicopers leak or unflyable on restart.
							} else {
								if (_selection in dayZ_explosiveParts and _dam > 0.8) then {_dam = 0.8};
							};
						[_object,_selection,_dam] call object_setFixServer;
						};
					} forEach _hitpoints;
					_object setvelocity [0,0,1];
					_object setFuel _fuel;
					_object call fnc_vehicleEventHandler;
					//Updated object position if moved
					if (!_wsDone) then {
						[_object, "position"] call server_updateObject;
					};
				};

				//Monitor the object
				//_object enableSimulation false;
				dayz_serverObjectMonitor set [count dayz_serverObjectMonitor,_object];
			};
		} forEach _myArray;
		
	// # END OF STREAMING #

// Spawn custom buildings
_cfgLocations = configFile >> "CfgChernarusRedux";

diag_log(format["ChernarusRedux Loading (%1)...", count _cfgLocations]);
for "_i" from 0 to ((count _cfgLocations) - 1) do 
{
	_config = _cfgLocations select _i;
	_locName = configName _config;

	_buildingList = configFile >> "CfgChernarusRedux" >> _locName;
	diag_log(format["Generating ChernarusRedux Buildings for: %1 (%2)", _locName, count _buildingList]);

	for "_j" from 0 to ((count _buildingList) - 1) do 
	{
		_config	= _buildingList select _j;
		if (isClass(_config)) then {
			_type		= getText(_config >> "type");
			_position	= [] + getArray	(_config >> "position");
			_dir		= getNumber	(_config >> "direction");
			_noTilt		= getNumber	(_config >> "noTilt");
		
			_object =  createVehicle [_type, _position, [], 0, "CAN_COLLIDE"];

			// noTilt means the building/object will not be tilted to match the terrain incline
			// However, you generally don't want this other than for proper cement buildings,
			// as doing a setDir after a setPos risks misplacement of the building
			if (_noTilt == 1) then {
				_object setDir _dir;
				_object setPos _position;
				_object setDir _dir;
			} else {
				_object setDir _dir;
				_object setPos _position;
			};

			_object allowDamage false;

			//Monitor the object
			//dayz_serverObjectMonitor set [count dayz_serverObjectMonitor,_object];

			diag_log(format["Added: %1", _type]);
		};
	};
};

	createCenter civilian;
	if (isDedicated) then {
		endLoadingScreen;
	};	
	
if (isDedicated) then {
	_id = [] execFSM "\z\addons\dayz_server\system\server_cleanup.fsm";
};

allowConnection = true;

// [_guaranteedLoot, _randomizedLoot, _frequency, _variance, _spawnChance, _spawnMarker, _spawnRadius, _spawnFire, _fadeFire]
//Randomize spawn chance, it may be a little cruel with a randomized amount but let's try it...
//private ["_random"];
_random = ceil(random 6) + 4; //Minimum of 40%

nul = [3, 4, (50 * 60), (15 * 60), _random/10, 'center', 4000, true, false] spawn server_spawnCrashSite;
//nul = [3, 4, (50 * 60), (15 * 60), 0.75, 'center', 4000, true, false] spawn server_spawnCrashSite;