package gd.eggs.net.client.connector;

import flash.utils.ByteArray;
import gd.eggs.net.client.IConnection.ConnectConfig;
import gd.eggs.net.client.IConnection.IConnector;
import gd.eggs.utils.Validate;
import haxe.Json;
import haxe.Timer;
import haxe.io.Bytes;
import haxe.io.Eof;

import sys.net.Host;
import sys.net.Socket;

#if cpp
import cpp.vm.Thread;
#elseif neko
import neko.vm.Thread;
#end

/**
 * @author Dukobpa3
 */
class SocketConnectSys extends BaseConnector implements IConnector {
	
	//=========================================================================
	//	PARAMETERS
	//=========================================================================
	
	public var connection(default, null):ConnectConfig;
	
	var _socket(default, null):Socket;
	
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
		super.init();
	}
	
	public function connect(config:ConnectConfig) {
		#if debug
		if(Validate.isNull(config)) throw "config is null";
		#end
		
		connection = config;
		
		try {
			_socket.connect(new Host(connection.server), connection.port);
			onSocketConnected();
			
			var sendThread:Thread = Thread.create(threadRead);
			sendThread.sendMessage(Thread.current());
		} catch (error:Dynamic) {
			onSocketError(error);
		}
	}
	
	public function close() {
		isOnline = false;
		_socket.close();
		signalClosed.dispatch( { message:"socket closed", config:connection } );
	}
	
	public function send(data:ByteArray) {
		try {
			_socket.output.writeBytes(data, 0, data.length);
		} catch (error:Dynamic) {
			onSocketError(error);
		}
	}
	
	//=========================================================================
	//	PRIVATE
	//=========================================================================
	
	function threadRead() {
		// wait for mainThreadLink from outside
		var mainThread:Thread = Thread.readMessage(true);
		
		// now go to working
		while (isOnline) {
			try {
				var sockArray:Array<Socket> = [_socket];
				var result = Socket.select(sockArray, null, null);
				for (s in result.read) {
					var data:ByteArray = new ByteArray();
					data.writeByte(s.input.readByte());
					onSocketData(data);
				}
			} catch (error:Dynamic) {
				//if (!Std.is(error, Eof)) {
					onSocketError(error);
				//} else {
					close();
				//}
			}
		}
	}
	
	function log(data:Dynamic) {
		signalLog.dispatch( { message:Json.stringify(data), config:connection } );
	}
	
	//=========================================================================
	//	HANDLERS
	//=========================================================================
	
	function onSocketConnected() {
		isOnline = true;
		signalConnected.dispatch( { message:"Connected", config:connection } );
	}
	
	function onSocketData(data:ByteArray) {
		signalData.dispatch(data);
	}
	
	function onSocketError(event:Dynamic) {
		signalConectError.dispatch( { message:Json.stringify(event), config:connection } );
	}

}