package gd.eggs.net.client;

import gd.eggs.net.client.INet;
import gd.eggs.utils.Validate;

import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.net.Socket;
import flash.utils.ByteArray;
import haxe.Json;

/**
 * @author Dukobpa3
 */
@:generic
class SocketConnectFlash extends BaseConnector implements IConnector {
	
	//=========================================================================
	//	PARAMETERS
	//=========================================================================
	
	var _socket:Socket;
	var _connectConfig:ConnectConfig;
	
	//=========================================================================
	//	CONSTRUCTOR
	//=========================================================================
	
	public function new() {
		super();
	}
	
	//=========================================================================
	//	PUBLIC
	//=========================================================================
	
	override public function init() {
		_socket = new Socket();
		_socket.addEventListener(Event.CONNECT, onSocketConnect);
		_socket.addEventListener(Event.CLOSE, onSocketClose);
		_socket.addEventListener(IOErrorEvent.IO_ERROR, onSocketError);
		_socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSocketError);
		_socket.addEventListener(ProgressEvent.SOCKET_DATA, onSocketData);
		
		super.init();
	}
	
	public function connect(config:ConnectConfig) {
		#if debug
		if(Validate.isNull(config)) throw "config is null";
		#end
		
		_connectConfig = config;
		try {
			if (isOnline) close();
			
			_socket.connect(_connectConfig.server, _connectConfig.port);
			isOnline = true;
		} catch (error:Dynamic) {
			onSocketError(error);
		}
	}
	
	public function close() {
		_socket.close();
		isOnline = false;
	}
	
	public function send(message:ByteArray) {
		#if debug
		if(Validate.isNull(message)) throw "message is null";
		#end
		
		try {
			#if debug
			if (!isOnline) throw "not connected";
			#end
			
			message.position = 0;
			
			_socket.writeBytes(message, 0, message.length);
			_socket.flush();
			
			var arr:Array<Dynamic> = ["sended", message];
			log(arr);
		} catch (error:Dynamic) {
			onSocketError(error);
		}
	}
	
	//=========================================================================
	//	PRIVATE
	//=========================================================================
	
	function log(data:Dynamic) {
		signalLog.dispatch( { message:Json.stringify(data), config:_connectConfig } );
	}
	
	//=========================================================================
	//	HANDLERS
	//=========================================================================
	
	function onSocketConnect(event:Event) {
		signalConnected.dispatch( { message:event.toString(), config:_connectConfig } );
	}
	
	function onSocketClose(event:Event) {
		isOnline = false;
		signalClosed.dispatch( { message:event.toString(), config:_connectConfig } );
	}
	
	function onSocketError(event:Dynamic) {
		signalConectError.dispatch( { message:event.toString(), config:_connectConfig } );
	}
	
	function onSocketData(_) {
		var data:ByteArray = new ByteArray();
		_socket.readBytes(data);
		
		var arr:Array<Dynamic> = ["received", data];
		log(arr);
		signalData.dispatch(data);
	}
	
}