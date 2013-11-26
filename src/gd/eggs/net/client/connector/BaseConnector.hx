package gd.eggs.net.client.connector;

import flash.utils.ByteArray;
import gd.eggs.net.client.IConnection.ConnectorEvent;
import gd.eggs.utils.DestroyUtils;
import gd.eggs.utils.IInitialize;
import gd.eggs.utils.Validate;
import msignal.Signal.Signal1;

/**
 * @author Dukobpa3
 */
class BaseConnector implements IInitialize {
	//=========================================================================
	//	PARAMETERS
	//=========================================================================
	
	public var isInited(default, null):Bool;
	public var isOnline(default, null):Bool;
	
	public var signalConectError(default, null):Signal1<ConnectorEvent>;
	public var signalConnected(default, null):Signal1<ConnectorEvent>;
	public var signalClosed(default, null):Signal1<ConnectorEvent>;
	public var signalLog(default, null):Signal1<ConnectorEvent>;
	public var signalData(default, null):Signal1<ByteArray>;
	
	//=========================================================================
	//	CONSTRUCTOR
	//=========================================================================
	
	public function new() {
		init();
	}
	
	//=========================================================================
	//	PUBLIC
	//=========================================================================
	
	public function init() {
		signalConectError = new Signal1<ConnectorEvent>();
		signalConnected = new Signal1<ConnectorEvent>();
		signalClosed = new Signal1<ConnectorEvent>();
		signalLog = new Signal1<ConnectorEvent>();
		signalData = new Signal1<ByteArray>();
		
		isInited = true;
	}
	
	public function destroy() {
		signalConectError = DestroyUtils.destroy(signalConectError);
		signalConnected = DestroyUtils.destroy(signalConnected);
		signalClosed = DestroyUtils.destroy(signalClosed);
		signalLog = DestroyUtils.destroy(signalLog);
		signalData = DestroyUtils.destroy(signalData);
		
		isInited = false;
	}
	
}