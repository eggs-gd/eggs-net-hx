package gd.eggs.net.client.connector;

import gd.eggs.net.client.IConnection.ConnectConfig;
import gd.eggs.net.client.IConnection.IConnector;
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
class SocketConnect extends AConnector {
	
	//=========================================================================
	//	PARAMETERS
	//=========================================================================
	
	var _socket(default, null):Socket;
	
	//=========================================================================
	//	CONSTRUCTOR
	//=========================================================================
	
	public function new() super();
	
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
	
	override public function destroy() {
		
		if (isOnline) close();
		
		_socket.removeEventListener(Event.CONNECT, onSocketConnect);
		_socket.removeEventListener(Event.CLOSE, onSocketClose);
		_socket.removeEventListener(IOErrorEvent.IO_ERROR, onSocketError);
		_socket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSocketError);
		_socket.removeEventListener(ProgressEvent.SOCKET_DATA, onSocketData);
	
		_socket = null;
		
		super.destroy();
	}
	
	override public function connect(config:ConnectConfig) {
		#if debug
		if(Validate.isNull(config)) throw "config is null";
		#end
		
		connection = config;
		try {
			if (isOnline) close();
			
			_socket.connect(connection.server, connection.port);
			isOnline = true;
		} catch (error:Dynamic) {
			onSocketError(error);
		}
	}
	
	override public function close() {
		_socket.close();
		isOnline = false;
	}
	
	override public function send(message:ByteArray) {
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
		} catch (error:Dynamic) {
			onSocketError(error);
		}
	}
	
	//=========================================================================
	//	PRIVATE
	//=========================================================================
	
	function log(data:Dynamic) {
		signalLog.dispatch( { message:Json.stringify(data), config:connection } );
	}
	
	//=========================================================================
	//	HANDLERS
	//=========================================================================
	
	function onSocketConnect(event:Event) {
		signalConnected.dispatch( { message:event.toString(), config:connection } );
	}
	
	function onSocketClose(event:Event) {
		isOnline = false;
		signalClosed.dispatch( { message:event.toString(), config:connection } );
	}
	
	function onSocketError(event:Dynamic) {
		signalConectError.dispatch( { message:event.toString(), config:connection } );
	}
	
	function onSocketData(_) {
		var data:ByteArray = new ByteArray();
		_socket.readBytes(data);
		
		signalData.dispatch(data);
	}
	
}