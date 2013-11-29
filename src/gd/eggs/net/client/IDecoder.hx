package gd.eggs.net.client;

import msignal.Signal;
import flash.utils.ByteArray;


/**
 * ...
 * @author Dukobpa3
 */

interface IDecoder<TSend, TReceive> {
	
	//=========================================================================
	//	PARAMETERS
	//=========================================================================
	
	// errors
	var signalInvalidDataType(default, null):Signal0;
	var signalInvalidPackageSize(default, null):Signal0;
	
	// status
	var signalInProgress(default, null):Signal0;
	var signalReceivingHeader(default, null):Signal0;
	
	var signalDone(default, null):Signal1<TReceive>;
	
	//=========================================================================
	//	METHODS
	//=========================================================================
	
	function parse(data:ByteArray):Void;
	function pack(message:TSend):ByteArray;
}