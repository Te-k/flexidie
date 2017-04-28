package com.naviina.bunit.jmunit;

import net.rim.device.api.util.Arrays;

/**
 * The AdvancedAssertion class is a suite for addons to the core assertions methods.
 * In the current release, it has nothing implemented.
 *
 * @author Brunno Silva
 * @since JMUnit 1.0
 */
public abstract class AdvancedAssertion extends Assertion{
	public static final void assertArrayEquals (String test, byte[] expected, byte[] actual) throws AssertionFailedException {
		if (!Arrays.equals(expected, actual)) {
			fail(test, expected, actual);
            unitTestLogic.addResultArray(new String[]{test, "assertArrayEquals", "fail"});
		} else {
			unitTestLogic.addResultArray(new String[]{test, "assertArrayEquals", "pass"});
		}
	}
	
	public static final void fail(String test, byte[] expected, byte[] actual) throws AssertionFailedException {
        System.out.println(test + " failed.");
        System.out.println("Expected " + expected + ", but was " + actual);
        unitTestLogic.addInfoStringArray(new String[]{test + " failed.", "Expected " + expected + ", but was " + actual});
    }
}
