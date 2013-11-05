import massive.munit.TestSuite;

import ExampleTest;
import gd.eggs.net.client.ServerProxyTest;

/**
 * Auto generated Test Suite for MassiveUnit.
 * Refer to munit command line tool for more information (haxelib run munit)
 */

class TestSuite extends massive.munit.TestSuite
{		

	public function new()
	{
		super();

		add(ExampleTest);
		add(gd.eggs.net.client.ServerProxyTest);
	}
}
