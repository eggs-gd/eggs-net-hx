package gd.eggs.net.client;

import gd.eggs.utils.IInitialize;
import msignal.Signal;
import flash.utils.ByteArray;


/**
 * @author Dukobpa3
 */
enum ConnectionType {
	socket;
	http;
	local;
}

typedef ConnectConfig = {
	type:EnumValue,
	server:String,
	port:Int,
	?id:String
}

typedef ConnectorEvent = {
	message:String,
	config:ConnectConfig
}

interface IConnector extends IInitialize {
	
	//=========================================================================
	//	VARIABLES
	//=========================================================================
	
	var isOnline(default, null):Bool;
	var connection(default, null):ConnectConfig;
	
	var signalConectError(default, null):Signal1<ConnectorEvent>;
	var signalConnected(default, null):Signal1<ConnectorEvent>;
	var signalClosed(default, null):Signal1<ConnectorEvent>;
	var signalLog(default, null):Signal1<ConnectorEvent>;
	var signalData(default, null):Signal1<ByteArray>;
	
	//=========================================================================
	//	METHODS
	//=========================================================================
	
	function connect(config:ConnectConfig):Void;
	
	function send(data:flash.utils.ByteArray):Void;
	
	function close():Void;
}