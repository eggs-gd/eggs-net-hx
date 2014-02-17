package gd.eggs.net.client;

import flash.utils.ByteArray;
import gd.eggs.net.client.IConnection.ConnectConfig;
import gd.eggs.net.client.IConnection.ConnectionType;
import gd.eggs.net.client.IConnection.ConnectorEvent;
import gd.eggs.net.client.IConnection.IConnector;
import gd.eggs.net.client.IDecoder;
import gd.eggs.utils.DestroyUtils;
import gd.eggs.utils.IInitialize;
import gd.eggs.utils.Validate;
import msignal.Signal.Signal1;


/**
 * @author Dukobpa3
 */
class ServerProxy implements IInitialize {
	
	//=========================================================================
	//	CONSTANTS
	//=========================================================================
	
	//=========================================================================
	//	PARAMETERS
	//=========================================================================
	
	public var isInited(default, null):Bool;
	
	public var signalConnected(default, null):Signal1<ConnectorEvent>;
	public var signalDisconnected(default, null):Signal1<ConnectorEvent>;
	public var signalError(default, null):Signal1<ConnectorEvent>;
	public var signalLog(default, null):Signal1<ConnectorEvent>;
	public var signalData(default, null):Signal1<Dynamic>;
	
	var _connector(default, null):IConnector;
	var _decoder(default, null):IDecoder<Dynamic, Dynamic>;
	
	var _messageQueue(default, null):Array<Dynamic>;
	
	//=========================================================================
	//	CONSTRUCTOR
	//=========================================================================
	
	public function new(decoder:IDecoder<Dynamic, Dynamic>, connector:IConnector) {
		#if debug
		if(Validate.isNull(decoder)) throw "decoder is null";
		if(Validate.isNull(connector)) throw "connector is null";
		#end
		
		_decoder = decoder;
		_connector = connector;
		
		init();
	}
	
	//=========================================================================
	//	PUBLIC
	//=========================================================================
	
	public function init() {
		_messageQueue = [];
		
		signalConnected = new Signal1<ConnectorEvent>();
		signalDisconnected = new Signal1<ConnectorEvent>();
		signalError = new Signal1<ConnectorEvent>();
		signalLog = new Signal1<ConnectorEvent>();
		signalData = new Signal1<Dynamic>();
		
		_decoder.signalInvalidPackageSize.add(onDecoderInvalidPackageSize);
		_decoder.signalInvalidDataType.add(onDecoderInvalidDataType);
		
		_decoder.signalReceivingHeader.add(onDecoderReceivingHeader);
		_decoder.signalInProgress.add(onDecoderProgress);
		_decoder.signalDone.add(onDecoderDone);
		
		_connector.signalConectError.add(onConnectorError);
		_connector.signalConnected.add(onConnectorConnected);
		_connector.signalClosed.add(onConnectorClosed);
		_connector.signalData.add(onConnectorData);
		_connector.signalLog.add(onConnectorLog);
		
		isInited = true;
	}
	
	public function destroy() {
		// TODO destroy konnector and decoder
		_messageQueue = DestroyUtils.destroy(_messageQueue);
		
		signalConnected = DestroyUtils.destroy(signalConnected);
		signalDisconnected = DestroyUtils.destroy(signalDisconnected);
		signalError = DestroyUtils.destroy(signalError);
		signalLog = DestroyUtils.destroy(signalLog);
		signalData = DestroyUtils.destroy(signalData);
		
		_decoder.signalInvalidPackageSize.remove(onDecoderInvalidPackageSize);
		_decoder.signalInvalidDataType.remove(onDecoderInvalidDataType);
		
		_decoder.signalReceivingHeader.remove(onDecoderReceivingHeader);
		_decoder.signalInProgress.remove(onDecoderProgress);
		_decoder.signalDone.remove(onDecoderDone);
		
		_connector.signalConectError.remove(onConnectorError);
		_connector.signalConnected.remove(onConnectorConnected);
		_connector.signalClosed.remove(onConnectorClosed);
		_connector.signalData.remove(onConnectorData);
		_connector.signalLog.remove(onConnectorLog);
		
		isInited = false;
	}
	
	public function connect(connection) {
		
		if (_connector.isOnline) {
			_connector.close();
		}
		
		_connector.connect(connection);
	}
	
	public function close() {
		
		if (_connector.isOnline) {
			_connector.close();
		}
	}
	
	public function sendMessage(message:Dynamic) {
		#if debug
		if(Validate.isNull(message)) throw "message is null";
		if(Validate.isNull(_connector)) throw "_connector is null, need to connect before";
		#end
		
		_connector.send(_decoder.pack(message));
	}
	
	//=========================================================================
	//	HANDLERS
	//=========================================================================
	//---------------------------------
	//	Connector events
	//---------------------------------
	function onConnectorError(event:ConnectorEvent) signalError.dispatch(event);
	
	function onConnectorConnected(event:ConnectorEvent) signalConnected.dispatch(event);
	
	function onConnectorClosed(event:ConnectorEvent) signalDisconnected.dispatch(event);
	
	function onConnectorLog(event:ConnectorEvent) signalLog.dispatch(event);
	
	function onConnectorData(data:ByteArray) _decoder.parse(data);
	
	//---------------------------------
	//	Decoder events
	//---------------------------------
	function onDecoderDone(data:Dynamic) signalData.dispatch(data);
	
	function onDecoderReceivingHeader() signalLog.dispatch({message:"Decoder receiving header", config:_connector.connection});
	
	function onDecoderProgress() signalLog.dispatch({message:"Decoder in progress", config:_connector.connection});
	
	function onDecoderInvalidPackageSize() signalError.dispatch({message:"Decoder error", config:_connector.connection});
	
	function onDecoderInvalidDataType() signalError.dispatch({message:"Decoder error", config:_connector.connection});
	
}