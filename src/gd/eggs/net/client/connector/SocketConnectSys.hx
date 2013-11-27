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
class SocketConnectSys extends AConnector {
	
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
		super.init();
	}
	
	override public function destroy() {
		// TODO check closing threads
		if (isOnline) close();
		_socket = null;
		super.destroy();
	}
	
	override public function connect(config:ConnectConfig) {
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
	
	override public function close() {
		isOnline = false;
		_socket.close();
		signalClosed.dispatch( { message:"socket closed", config:connection } );
	}
	
	override public function send(data:ByteArray) {
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
			
			var data:ByteArray = new ByteArray();
			var received:Bool = false;
			
			try {
				
				while(true) {
					var sockets = Socket.select([_socket], null, null);
					if(sockets.read.length > 0) {
						data.writeByte(_socket.input.readByte());
						received = true;
					}
					else break;
				}
				
				if (received) {
					onSocketData(data);
					data.clear();
					received = false;
				}
			
			} catch(error:Dynamic) {
				onSocketError(error);
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