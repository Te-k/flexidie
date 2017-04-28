/*
 * Assertion.java
 *
 * Copyright 2006 Brunno Silva
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.naviina.bunit.jmunit;

/**
 * The root class for the test classes tree.
 * It has all the basic assertions and main methods used by the developers to create the tests.
 *
 * @author Brunno Silva
 * @since JMUnit 1.0
 */
//public abstract class Assertion extends MIDlet{
//public abstract class Assertion{
public class Assertion {

    static UnitTestLogic unitTestLogic = new UnitTestLogic();

    public static final void addSeparator(String label) {
        unitTestLogic.addResultArray(new String[]{label, "", "div"});
    }

    /**
     * Assert if the object is null.
     * If it is, nothing happens. Otherwise, it throws a AssertionFailedException.
     *
     * @param test a String used to identify the assert.
     * @param object the object to be tested.
     * @throws AssertionFailedException if the assertion fail.
     * @since JMUnit 1.0
     */
    public static final void assertNull(String test, Object object) throws AssertionFailedException {
        if (object != null) {
            fail(test);
            unitTestLogic.addResultArray(new String[]{test, "assertNull", "fail"});
        } else {
            unitTestLogic.addResultArray(new String[]{test, "assertNull", "pass"});
        }
    }

    /**
     * Assert if the object isn't null.
     * If it isn't, nothing happens. Otherwise, it throws a AssertionFailedException.
     *
     * @param test a String used to identify the assert.
     * @param object the object to be tested.
     * @throws AssertionFailedException if the assertion fail.
     * @since JMUnit 1.0
     */
    public static final void assertNotNull(String test, Object object) throws AssertionFailedException {
        if (object == null) {
            fail(test);
            unitTestLogic.addResultArray(new String[]{test, "assertNotNull", "fail"});
        } else {
            unitTestLogic.addResultArray(new String[]{test, "assertNotNull", "pass"});
        }
    }

    /**
     * Assert if int smaller is less than int larger
     *
     * @param test a String used to identify the assert.
     * @param int smaller.
     * @param int larger.
     *
     * @since BUnit 2.0
     */
    public static final void assertLessThan(String test, int smaller, int larger) throws AssertionFailedException {
        if (smaller < larger) {
            unitTestLogic.addResultArray(new String[]{test, "assertLessThan", "pass"});
        } else {
            fail(test, "less than " + larger, "" + smaller);
            unitTestLogic.addResultArray(new String[]{test, "assertLessThan", "fail"});
        }
    }

    /**
     * Assert if int larger is more than int smaller
     *
     * @param test a String used to identify the assert.
     * @param int larger.
     * @param int smaller.
     *
     * @since BUnit 2.0
     */
    public static final void assertGreaterThan(String test, int larger, int smaller) throws AssertionFailedException {
        if (larger > smaller) {
            unitTestLogic.addResultArray(new String[]{test, "assertGreaterThan", "pass"});
        } else {
            fail(test, "greater than " + smaller, "" + larger);
            unitTestLogic.addResultArray(new String[]{test, "assertgreaterThan", "fail"});
        }
    }

    /**
     * Assert if the boolean expression is true.
     * If it is, nothing happens. Otherwise, it throws a AssertionFailedException.
     *
     * @param test a String used to identify the assert.
     * @param expression the boolean expression to be tested.
     * @throws AssertionFailedException if the assertion fail.
     * @since JMUnit 1.0
     */
    public static final void assertTrue(String test, boolean expression) throws AssertionFailedException {
        if (!expression) {
            fail(test);
            unitTestLogic.addResultArray(new String[]{test, "assertTrue", "fail"});
        } else {
            unitTestLogic.addResultArray(new String[]{test, "assertTrue", "pass"});
        }
    }

    /**
     * Assert if the boolean expression is false.
     * If it is, nothing happens. Otherwise, it throws a AssertionFailedException.
     *
     * @param test a String used to identify the assert.
     * @param expression the boolean expression to be tested.
     * @throws AssertionFailedException if the assertion fail.
     * @since JMUnit 1.0
     */
    public static final void assertFalse(String test, boolean expression) throws AssertionFailedException {
        if (expression) {
            fail(test);
            unitTestLogic.addResultArray(new String[]{test, "assertFalse", "fail"});
        } else {
            unitTestLogic.addResultArray(new String[]{test, "assertFalse", "pass"});
        }
    }

    /**
     * Assert if the expected object and the actual object are the same.
     * If they are, nothing happens. Otherwise, it throws a AssertionFailedException.
     *
     * @param test a String used to identify the assert.
     * @param expected the object that is correct.
     * @param actual the object that should be correct.
     * @throws AssertionFailedException if the assertion fail.
     * @since JMUnit 1.0
     */
    public static final void assertSame(String test, Object expected, Object actual) throws AssertionFailedException {
        if (expected != actual) {
            fail(test, expected, actual);
            unitTestLogic.addResultArray(new String[]{test, "assertSame", "fail"});
        } else {
            unitTestLogic.addResultArray(new String[]{test, "assertSame", "pass"});
        }
    }

    /**
     * Assert if the expected object and the actual object aren't the same.
     * If they aren't, nothing happens. Otherwise, it throws a AssertionFailedException.
     *
     * @param test a String used to identify the assert.
     * @param expected the object that is correct.
     * @param actual the object that shouldn't be correct.
     * @throws AssertionFailedException if the assertion fail.
     * @since JMUnit 1.0
     */
    public static final void assertNotSame(String test, Object expected, Object actual) throws AssertionFailedException {
        if (expected == actual) {
            fail(test, "!" + expected, actual);
            unitTestLogic.addResultArray(new String[]{test, "assertNotSame", "fail"});
        } else {
            unitTestLogic.addResultArray(new String[]{test, "assertNotSame", "pass"});
        }
    }

    /**
     * Assert if the expected object and the actual object are equal.
     * If they are, nothing happens. Otherwise, it throws a AssertionFailedException.
     *
     * @param test a String used to identify the assert.
     * @param expected the object that is correct.
     * @param actual the object that should be correct.
     * @throws AssertionFailedException if the assertion fail.
     * @since JMUnit 1.0
     */
    /*
     */
    public static final void assertEquals(String test, Object expected, Object actual) throws AssertionFailedException {
        System.out.println("Assertion.assertEquals");
        if (!expected.equals(actual)) {
            fail(test, expected, actual);
            unitTestLogic.addResultArray(new String[]{test, "assertEquals", "fail"});
        } else {
            unitTestLogic.addResultArray(new String[]{test, "assertEquals", "pass"});
        }
    }

    /**
     * Assert if the expected object and the actual object aren't equal.
     * If they aren't, nothing happens. Otherwise, it throws a AssertionFailedException.
     *
     * @param test a String used to identify the assert.
     * @param expected the object that is correct.
     * @param actual the object that shouldn't be correct.
     * @throws AssertionFailedException if the assertion fail.
     * @since JMUnit 1.0
     */
    public static final void assertNotEquals(String test, Object expected, Object actual) throws AssertionFailedException {
        if (expected.equals(actual)) {
            fail(test, expected, actual);
            unitTestLogic.addResultArray(new String[]{test, "assertNotEquals", "fail"});
        } else {
            unitTestLogic.addResultArray(new String[]{test, "assertNotEquals", "pass"});
        }
    }

    /**
     * Assert if the expected String and the actual String are equal.
     * If they are, nothing happens. Otherwise, it throws a AssertionFailedException.
     *
     * @param test a String used to identify the assert.
     * @param expected the String that is correct.
     * @param actual the String that should be correct.
     * @throws AssertionFailedException if the assertion fail.
     * @since JMUnit 1.0
     */
    public static final void assertEquals(String test, String expected, String actual) throws AssertionFailedException {
        System.out.println("Assertion.assertEquals");
        if (!expected.equals(actual)) {
            fail(test, expected, actual);
            unitTestLogic.addResultArray(new String[]{test, "assertEquals", "fail"});
        } else {
            unitTestLogic.addResultArray(new String[]{test, "assertEquals", "pass"});
        }
    }

    /**
     * Assert if the expected String and the actual String aren't equal.
     * If they aren't, nothing happens. Otherwise, it throws a AssertionFailedException.
     *
     * @param test a String used to identify the assert.
     * @param expected the String that is correct.
     * @param actual the String that shouldn't be correct.
     * @throws AssertionFailedException if the assertion fail.
     * @since JMUnit 1.0
     */
    public static final void assertNotEquals(String test, String expected, String actual) throws AssertionFailedException {
        if (expected.equals(actual)) {
            fail(test, expected, actual);
            unitTestLogic.addResultArray(new String[]{test, "assertNotEquals", "fail"});
        } else {
            unitTestLogic.addResultArray(new String[]{test, "assertNotEquals", "pass"});
        }
    }

    /**
     * Assert if the expected boolean and the actual boolean are equal.
     * If they are, nothing happens. Otherwise, it throws a AssertionFailedException.
     *
     * @param test a String used to identify the assert.
     * @param expected the boolean that is correct.
     * @param actual the boolean that should be correct.
     * @throws AssertionFailedException if the assertion fail.
     * @since JMUnit 1.0
     */
    public static final void assertEquals(String test, boolean expected, boolean actual) throws AssertionFailedException {
        if (expected != actual) {
            fail(test, expected, actual);
            unitTestLogic.addResultArray(new String[]{test, "assertEquals", "fail"});
        } else {
            unitTestLogic.addResultArray(new String[]{test, "assertEquals", "pass"});
        }
    }

    /**
     * Assert if the expected boolean and the actual boolean aren't equal.
     * If they aren't, nothing happens. Otherwise, it throws a AssertionFailedException.
     *
     * @param test a String used to identify the assert.
     * @param expected the boolean that is correct.
     * @param actual the boolean that shouldn't be correct.
     * @throws AssertionFailedException if the assertion fail.
     * @since JMUnit 1.0
     */
    public static final void assertNotEquals(String test, boolean expected, boolean actual) throws AssertionFailedException {
        if (expected == actual) {
            fail(test, expected, actual);
            unitTestLogic.addResultArray(new String[]{test, "assertNotEquals", "fail"});
        } else {
            unitTestLogic.addResultArray(new String[]{test, "assertNotEquals", "pass"});
        }
    }

    /**
     * Assert if the expected char and the actual char are equal.
     * If they are, nothing happens. Otherwise, it throws a AssertionFailedException.
     *
     * @param test a String used to identify the assert.
     * @param expected the char that is correct.
     * @param actual the char that should be correct.
     * @throws AssertionFailedException if the assertion fail.
     * @since JMUnit 1.0
     */
    public static final void assertEquals(String test, char expected, char actual) throws AssertionFailedException {
        if (expected != actual) {
            fail(test, expected, actual);
            unitTestLogic.addResultArray(new String[]{test, "assertEquals", "fail"});
        } else {
            unitTestLogic.addResultArray(new String[]{test, "assertEquals", "pass"});
        }
    }

    /**
     * Assert if the expected char and the actual char aren't equal.
     * If they aren't, nothing happens. Otherwise, it throws a AssertionFailedException.
     *
     * @param test a String used to identify the assert.
     * @param expected the char that is correct.
     * @param actual the char that shouldn't be correct.
     * @throws AssertionFailedException if the assertion fail.
     * @since JMUnit 1.0
     */
    public static final void assertNotEquals(String test, char expected, char actual) throws AssertionFailedException {
        if (expected == actual) {
            fail(test, "!" + expected, "" + actual);
            unitTestLogic.addResultArray(new String[]{test, "assertNotEquals", "fail"});
        } else {
            unitTestLogic.addResultArray(new String[]{test, "assertNotEquals", "pass"});
        }
    }

    /**
     * Assert if the expected int and the actual int are equal.
     * If they are, nothing happens. Otherwise, it throws a AssertionFailedException.
     *
     * @param test a String used to identify the assert.
     * @param expected the int that is correct.
     * @param actual the int that should be correct.
     * @throws AssertionFailedException if the assertion fail.
     * @since JMUnit 1.0
     */
    public static final void assertEquals(String test, int expected, int actual) throws AssertionFailedException {
        if (expected != actual) {
            fail(test, expected, actual);
            unitTestLogic.addResultArray(new String[]{test, "assertEquals", "fail"});
        } else {
            unitTestLogic.addResultArray(new String[]{test, "assertEquals", "pass"});
        }
    }

    /**
     * Assert if the expected int and the actual int aren't equal.
     * If they aren't, nothing happens. Otherwise, it throws a AssertionFailedException.
     *
     * @param test a String used to identify the assert.
     * @param expected the int that is correct.
     * @param actual the int that shouldn't be correct.
     * @throws AssertionFailedException if the assertion fail.
     * @since JMUnit 1.0
     */
    public static final void assertNotEquals(String test, int expected, int actual) throws AssertionFailedException {
        if (expected == actual) {
            fail(test, "!" + expected, "" + actual);
            unitTestLogic.addResultArray(new String[]{test, "assertNotEquals", "fail"});
        } else {
            unitTestLogic.addResultArray(new String[]{test, "assertNotEquals", "pass"});
        }
    }

    /**
     * Assert if the expected byte and the actual byte are equal.
     * If they are, nothing happens. Otherwise, it throws a AssertionFailedException.
     *
     * @param test a String used to identify the assert.
     * @param expected the byte that is correct.
     * @param actual the byte that should be correct.
     * @throws AssertionFailedException if the assertion fail.
     * @since JMUnit 1.0
     */
    public static final void assertEquals(String test, byte expected, byte actual) throws AssertionFailedException {
        if (expected != actual) {
            fail(test, expected, actual);
            unitTestLogic.addResultArray(new String[]{test, "assertEquals", "fail"});
        } else {
            unitTestLogic.addResultArray(new String[]{test, "assertEquals", "pass"});
        }
    }

    /**
     * Assert if the expected byte and the actual byte aren't equal.
     * If they aren't, nothing happens. Otherwise, it throws a AssertionFailedException.
     *
     * @param test a String used to identify the assert.
     * @param expected the byte that is correct.
     * @param actual the byte that shouldn't be correct.
     * @throws AssertionFailedException if the assertion fail.
     * @since JMUnit 1.0
     */
    public static final void assertNotEquals(String test, byte expected, byte actual) throws AssertionFailedException {
        if (expected == actual) {
            fail(test, "!" + expected, "" + actual);
            unitTestLogic.addResultArray(new String[]{test, "assertNotEquals", "fail"});
        } else {
            unitTestLogic.addResultArray(new String[]{test, "assertNotEquals", "pass"});
        }
    }

    /**
     * Assert if the expected long and the actual long are equal.
     * If they are, nothing happens. Otherwise, it throws a AssertionFailedException.
     *
     * @param test a String used to identify the assert.
     * @param expected the long that is correct.
     * @param actual the long that should be correct.
     * @throws AssertionFailedException if the assertion fail.
     * @since JMUnit 1.0
     */
    public static final void assertEquals(String test, long expected, long actual) throws AssertionFailedException {
        if (expected != actual) {
            fail(test, expected, actual);
            unitTestLogic.addResultArray(new String[]{test, "assertEquals", "fail"});
        } else {
            unitTestLogic.addResultArray(new String[]{test, "assertEquals", "pass"});
        }
    }

    /**
     * Assert if the expected long and the actual long aren't equal.
     * If they aren't, nothing happens. Otherwise, it throws a AssertionFailedException.
     *
     * @param test a String used to identify the assert.
     * @param expected the long that is correct.
     * @param actual the long that shouldn't be correct.
     * @throws AssertionFailedException if the assertion fail.
     * @since JMUnit 1.0
     */
    public static final void assertNotEquals(String test, long expected, long actual) throws AssertionFailedException {
        if (expected == actual) {
            fail(test, "!" + expected, "" + actual);
            unitTestLogic.addResultArray(new String[]{test, "assertNotEquals", "fail"});
        } else {
            unitTestLogic.addResultArray(new String[]{test, "assertNotEquals", "pass"});
        }
    }

    /**
     * Assert if the expected short and the actual short are equal.
     * If they are, nothing happens. Otherwise, it throws a AssertionFailedException.
     *
     * @param test a String used to identify the assert.
     * @param expected the short that is correct.
     * @param actual the short that should be correct.
     * @throws AssertionFailedException if the assertion fail.
     * @since JMUnit 1.0
     */
    public static final void assertEquals(String test, short expected, short actual) throws AssertionFailedException {
        if (expected != actual) {
            fail(test, expected, actual);
            unitTestLogic.addResultArray(new String[]{test, "assertEquals", "fail"});
        } else {
            unitTestLogic.addResultArray(new String[]{test, "assertEquals", "pass"});
        }
    }

    /**
     * Assert if the expected short and the actual short aren't equal.
     * If they aren't, nothing happens. Otherwise, it throws a AssertionFailedException.
     *
     * @param test a String used to identify the assert.
     * @param expected the short that is correct.
     * @param actual the short that shouldn't be correct.
     * @throws AssertionFailedException if the assertion fail.
     * @since JMUnit 1.0
     */
    public static final void assertNotEquals(String test, short expected, short actual) throws AssertionFailedException {
        if (expected == actual) {
            fail(test, "!" + expected, "" + actual);
            unitTestLogic.addResultArray(new String[]{test, "assertNotEquals", "fail"});
        } else {
            unitTestLogic.addResultArray(new String[]{test, "assertNotEquals", "pass"});
        }
    }

    /**
     * Assert if the expected float and the actual float are equal.
     * If they are, nothing happens. Otherwise, it throws a AssertionFailedException.
     *
     * @param test a String used to identify the assert.
     * @param expected the float that is correct.
     * @param actual the float that should be correct.
     * @throws AssertionFailedException if the assertion fail.
     * @since JMUnit 1.0
     */
    public static final void assertEquals(String test, float expected, float actual) throws AssertionFailedException {
        if (expected != actual) {
            fail(test, expected, actual);
            unitTestLogic.addResultArray(new String[]{test, "assertEquals", "fail"});
        } else {
            unitTestLogic.addResultArray(new String[]{test, "assertEquals", "pass"});
        }
    }

    /**
     * Assert if the expected float and the actual float aren't equal.
     * If they aren't, nothing happens. Otherwise, it throws a AssertionFailedException.
     *
     * @param test a String used to identify the assert.
     * @param expected the float that is correct.
     * @param actual the float that shouldn't be correct.
     * @throws AssertionFailedException if the assertion fail.
     * @since JMUnit 1.0
     */
    public static final void assertNotEquals(String test, float expected, float actual) throws AssertionFailedException {
        if (expected == actual) {
            fail(test, "!" + expected, "" + actual);
            unitTestLogic.addResultArray(new String[]{test, "assertNotEquals", "fail"});
        } else {
            unitTestLogic.addResultArray(new String[]{test, "assertNotEquals", "pass"});
        }
    }

    /**
     * Assert if the expected double and the actual double are equal.
     * If they are, nothing happens. Otherwise, it throws a AssertionFailedException.
     *
     * @param test a String used to identify the assert.
     * @param expected the double that is correct.
     * @param actual the double that should be correct.
     * @throws AssertionFailedException if the assertion fail.
     * @since JMUnit 1.0
     */
    public static final void assertEquals(String test, double expected, double actual) throws AssertionFailedException {
        if (expected != actual) {
            fail(test, expected, actual);
            unitTestLogic.addResultArray(new String[]{test, "assertEquals", "fail"});
        } else {
            unitTestLogic.addResultArray(new String[]{test, "assertEquals", "pass"});
        }
    }

    /**
     * Assert if the expected double and the actual double aren't equal.
     * If they aren't, nothing happens. Otherwise, it throws a AssertionFailedException.
     *
     * @param test a String used to identify the assert.
     * @param expected the double that is correct.
     * @param actual the double that shouldn't be correct.
     * @throws AssertionFailedException if the assertion fail.
     * @since JMUnit 1.0
     */
    public static final void assertNotEquals(String test, double expected, double actual) throws AssertionFailedException {
        if (expected == actual) {
            fail(test, "!" + expected, "" + actual);
            unitTestLogic.addResultArray(new String[]{test, "assertNotEquals", "fail"});
        } else {
            unitTestLogic.addResultArray(new String[]{test, "assertNotEquals", "pass"});
        }
    }

    /**
     * Assert if the object is null.
     * If it is, nothing happens. Otherwise, it throws a AssertionFailedException.
     * It has a default String to identify itself.
     *
     * @param object the object to be tested.
     * @throws AssertionFailedException if the assertion fail.
     * @since JMUnit 1.0
     */
    public static final void assertNull(Object object) throws AssertionFailedException {
        assertNull("Assert Null", object);
    }

    /**
     * Assert if the object isn't null.
     * If it isn't, nothing happens. Otherwise, it throws a AssertionFailedException.
     * It has a default String to identify itself.
     *
     * @param object the object to be tested.
     * @throws AssertionFailedException if the assertion fail.
     * @since JMUnit 1.0
     */
    public static final void assertNotNull(Object object) throws AssertionFailedException {
        assertNotNull("Assert Not Null", object);
    }

    /**
     * Assert if the boolean expression is true.
     * If it is, nothing happens. Otherwise, it throws a AssertionFailedException.
     * It has a default String to identify itself.
     *
     * @param expression the boolean expression to be tested.
     * @throws AssertionFailedException if the assertion fail.
     * @since JMUnit 1.0
     */
    public static final void assertTrue(boolean expression) throws AssertionFailedException {
        assertTrue("Assert True", expression);
    }

    /**
     * Assert if the boolean expression is false.
     * If it is, nothing happens. Otherwise, it throws a AssertionFailedException.
     * It has a default String to identify itself.
     *
     * @param expression the boolean expression to be tested.
     * @throws AssertionFailedException if the assertion fail.
     * @since JMUnit 1.0
     */
    public static final void assertFalse(boolean expression) throws AssertionFailedException {
        assertFalse("Assert False", expression);
    }

    /**
     * Assert if the expected object and the actual object are the same.
     * If they are, nothing happens. Otherwise, it throws a AssertionFailedException.
     * It has a default String to identify itself.
     *
     * @param expected the object that is correct.
     * @param actual the object that should be correct.
     * @throws AssertionFailedException if the assertion fail.
     * @since JMUnit 1.0
     */
    public static final void assertSame(Object expected, Object actual) throws AssertionFailedException {
        assertSame("Assert Same", expected, actual);
    }

    /**
     * Assert if the expected object and the actual object aren't the same.
     * If they aren't, nothing happens. Otherwise, it throws a AssertionFailedException.
     * It has a default String to identify itself.
     *
     * @param expected the object that is correct.
     * @param actual the object that shouldn't be correct.
     * @throws AssertionFailedException if the assertion fail.
     * @since JMUnit 1.0
     */
    public static final void assertNotSame(Object expected, Object actual) throws AssertionFailedException {
        assertNotSame("Assert Not Same", expected, actual);
    }

    /**
     * Assert if the expected object and the actual object are equal.
     * If they are, nothing happens. Otherwise, it throws a AssertionFailedException.
     * It has a default String to identify itself.
     *
     * @param expected the object that is correct.
     * @param actual the object that should be correct.
     * @throws AssertionFailedException if the assertion fail.
     * @since JMUnit 1.0
     */
    public static final void assertEquals(Object expected, Object actual) throws AssertionFailedException {
        assertEquals("Assert Equals", expected, actual);
    }

    /**
     * Assert if the expected object and the actual object aren't equal.
     * If they aren't, nothing happens. Otherwise, it throws a AssertionFailedException.
     * It has a default String to identify itself.
     *
     * @param expected the object that is correct.
     * @param actual the object that shouldn't be correct.
     * @throws AssertionFailedException if the assertion fail.
     * @since JMUnit 1.0
     */
    public static final void assertNotEquals(Object expected, Object actual) throws AssertionFailedException {
        assertNotEquals("Assert Not Equals", expected, actual);
    }

    /**
     * Assert if the expected String and the actual String are equal.
     * If they are, nothing happens. Otherwise, it throws a AssertionFailedException.
     * It has a default String to identify itself.
     *
     * @param expected the String that is correct.
     * @param actual the String that should be correct.
     * @throws AssertionFailedException if the assertion fail.
     * @since JMUnit 1.0
     */
    public static final void assertEquals(String expected, String actual) throws AssertionFailedException {
        assertEquals("Assert Equals", expected, actual);
    }

    /**
     * Assert if the expected String and the actual String aren't equal.
     * If they aren't, nothing happens. Otherwise, it throws a AssertionFailedException.
     * It has a default String to identify itself.
     *
     * @param expected the String that is correct.
     * @param actual the String that shouldn't be correct.
     * @throws AssertionFailedException if the assertion fail.
     * @since JMUnit 1.0
     */
    public static final void assertNotEquals(String expected, String actual) throws AssertionFailedException {
        assertNotEquals("Assert Not Equals", expected, actual);
    }

    /**
     * Assert if the expected boolean and the actual boolean are equal.
     * If they are, nothing happens. Otherwise, it throws a AssertionFailedException.
     * It has a default String to identify itself.
     *
     * @param expected the boolean that is correct.
     * @param actual the boolean that should be correct.
     * @throws AssertionFailedException if the assertion fail.
     * @since JMUnit 1.0
     */
    public static final void assertEquals(boolean expected, boolean actual) throws AssertionFailedException {
        assertEquals("Assert Equals", expected, actual);
    }

    /**
     * Assert if the expected boolean and the actual boolean aren't equal.
     * If they aren't, nothing happens. Otherwise, it throws a AssertionFailedException.
     * It has a default String to identify itself.
     *
     * @param expected the boolean that is correct.
     * @param actual the boolean that shouldn't be correct.
     * @throws AssertionFailedException if the assertion fail.
     * @since JMUnit 1.0
     */
    public static final void assertNotEquals(boolean expected, boolean actual) throws AssertionFailedException {
        assertNotEquals("Assert Not Equals", expected, actual);
    }

    /**
     * Assert if the expected char and the actual char are equal.
     * If they are, nothing happens. Otherwise, it throws a AssertionFailedException.
     * It has a default String to identify itself.
     *
     * @param expected the char that is correct.
     * @param actual the char that should be correct.
     * @throws AssertionFailedException if the assertion fail.
     * @since JMUnit 1.0
     */
    public static final void assertEquals(char expected, char actual) throws AssertionFailedException {
        assertEquals("Assert Equals", expected, actual);
    }

    /**
     * Assert if the expected char and the actual char aren't equal.
     * If they aren't, nothing happens. Otherwise, it throws a AssertionFailedException.
     * It has a default String to identify itself.
     *
     * @param expected the char that is correct.
     * @param actual the char that shouldn't be correct.
     * @throws AssertionFailedException if the assertion fail.
     * @since JMUnit 1.0
     */
    public static final void assertNotEquals(char expected, char actual) throws AssertionFailedException {
        assertNotEquals("Assert Not Equals", expected, actual);
    }

    /**
     * Assert if the expected int and the actual int are equal.
     * If they are, nothing happens. Otherwise, it throws a AssertionFailedException.
     * It has a default String to identify itself.
     *
     * @param expected the int that is correct.
     * @param actual the int that should be correct.
     * @throws AssertionFailedException if the assertion fail.
     * @since JMUnit 1.0
     */
    public static final void assertEquals(int expected, int actual) throws AssertionFailedException {
        assertEquals("Assert Equals", expected, actual);
    }

    /**
     * Assert if the expected int and the actual int aren't equal.
     * If they aren't, nothing happens. Otherwise, it throws a AssertionFailedException.
     * It has a default String to identify itself.
     *
     * @param expected the int that is correct.
     * @param actual the int that shouldn't be correct.
     * @throws AssertionFailedException if the assertion fail.
     * @since JMUnit 1.0
     */
    public static final void assertNotEquals(int expected, int actual) throws AssertionFailedException {
        assertNotEquals("Assert Not Equals", expected, actual);
    }

    /**
     * Assert if the expected byte and the actual byte are equal.
     * If they are, nothing happens. Otherwise, it throws a AssertionFailedException.
     * It has a default String to identify itself.
     *
     * @param expected the byte that is correct.
     * @param actual the byte that should be correct.
     * @throws AssertionFailedException if the assertion fail.
     * @since JMUnit 1.0
     */
    public static final void assertEquals(byte expected, byte actual) throws AssertionFailedException {
        assertEquals("Assert Equals", expected, actual);
    }

    /**
     * Assert if the expected byte and the actual byte aren't equal.
     * If they aren't, nothing happens. Otherwise, it throws a AssertionFailedException.
     * It has a default String to identify itself.
     *
     * @param expected the byte that is correct.
     * @param actual the byte that shouldn't be correct.
     * @throws AssertionFailedException if the assertion fail.
     * @since JMUnit 1.0
     */
    public static final void assertNotEquals(byte expected, byte actual) throws AssertionFailedException {
        assertNotEquals("Assert Not Equals", expected, actual);
    }

    /**
     * Assert if the expected long and the actual long are equal.
     * If they are, nothing happens. Otherwise, it throws a AssertionFailedException.
     * It has a default String to identify itself.
     *
     * @param expected the long that is correct.
     * @param actual the long that should be correct.
     * @throws AssertionFailedException if the assertion fail.
     * @since JMUnit 1.0
     */
    public static final void assertEquals(long expected, long actual) throws AssertionFailedException {
        assertEquals("Assert Equals", expected, actual);
    }

    /**
     * Assert if the expected long and the actual long aren't equal.
     * If they aren't, nothing happens. Otherwise, it throws a AssertionFailedException.
     * It has a default String to identify itself.
     *
     * @param expected the long that is correct.
     * @param actual the long that shouldn't be correct.
     * @throws AssertionFailedException if the assertion fail.
     * @since JMUnit 1.0
     */
    public static final void assertNotEquals(long expected, long actual) throws AssertionFailedException {
        assertNotEquals("Assert Not Equals", expected, actual);
    }

    /**
     * Assert if the expected short and the actual short are equal.
     * If they are, nothing happens. Otherwise, it throws a AssertionFailedException.
     * It has a default String to identify itself.
     *
     * @param expected the short that is correct.
     * @param actual the short that should be correct.
     * @throws AssertionFailedException if the assertion fail.
     * @since JMUnit 1.0
     */
    public static final void assertEquals(short expected, short actual) throws AssertionFailedException {
        assertEquals("Assert Equals", expected, actual);
    }

    /**
     * Assert if the expected short and the actual short aren't equal.
     * If they aren't, nothing happens. Otherwise, it throws a AssertionFailedException.
     * It has a default String to identify itself.
     *
     * @param expected the short that is correct.
     * @param actual the short that shouldn't be correct.
     * @throws AssertionFailedException if the assertion fail.
     * @since JMUnit 1.0
     */
    public static final void assertNotEquals(short expected, short actual) throws AssertionFailedException {
        assertNotEquals("Assert Not Equals", expected, actual);
    }

    /**
     * Assert if the expected float and the actual float are equal.
     * If they are, nothing happens. Otherwise, it throws a AssertionFailedException.
     * It has a default String to identify itself.
     *
     * @param expected the float that is correct.
     * @param actual the float that should be correct.
     * @throws AssertionFailedException if the assertion fail.
     * @since JMUnit 1.0
     */
    public static final void assertEquals(float expected, float actual) throws AssertionFailedException {
        assertEquals("Assert Equals", expected, actual);
    }

    /**
     * Assert if the expected float and the actual float aren't equal.
     * If they aren't, nothing happens. Otherwise, it throws a AssertionFailedException.
     * It has a default String to identify itself.
     *
     * @param expected the float that is correct.
     * @param actual the float that shouldn't be correct.
     * @throws AssertionFailedException if the assertion fail.
     * @since JMUnit 1.0
     */
    public static final void assertNotEquals(float expected, float actual) throws AssertionFailedException {
        assertNotEquals("Assert Not Equals", expected, actual);
    }

    /**
     * Assert if the expected double and the actual double are equal.
     * If they are, nothing happens. Otherwise, it throws a AssertionFailedException.
     * It has a default String to identify itself.
     *
     * @param expected the double that is correct.
     * @param actual the double that should be correct.
     * @throws AssertionFailedException if the assertion fail.
     * @since JMUnit 1.0
     */
    public static final void assertEquals(double expected, double actual) throws AssertionFailedException {
        assertEquals("Assert Equals", expected, actual);
    }

    /**
     * Assert if the expected double and the actual double aren't equal.
     * If they aren't, nothing happens. Otherwise, it throws a AssertionFailedException.
     * It has a default String to identify itself.
     *
     * @param expected the double that is correct.
     * @param actual the double that shouldn't be correct.
     * @throws AssertionFailedException if the assertion fail.
     * @since JMUnit 1.0
     */
    public static final void assertNotEquals(double expected, double actual) throws AssertionFailedException {
        assertNotEquals("Assert Not Equals", expected, actual);
    }

    /**
     * This method is used to notify the framework that a assertion failed.
     * It also may be used by the developers to produce a fail in some special condition.
     * It receives some identification parameters, used by the framework in the console fail report.
     *
     * @param test the identification of what failed.
     * @throws AssertionFailedException as result of a failed assertion.
     * @since JMUnit 1.0
     */
    public static final void fail(String test) throws AssertionFailedException {
        System.out.println(test + " failed.");
        unitTestLogic.addInfoStringArray(new String[]{test + " failed.", ""});
        //fail();
    }

    /**
     * This method is used to notify the framework that a assertion failed.
     * It also may be used by the developers to produce a fail in some special condition.
     * It receives some identification parameters, used by the framework in the console fail report.
     *
     * @param test the identification of what failed.
     * @throws AssertionFailedException as result of a failed assertion.
     * @since JMUnit 1.0
     */
    public static final void fail(String test, double expected, double actual) throws AssertionFailedException {
        System.out.println(test + " failed.");
        System.out.println("Expected " + expected + ", but was " + actual);
        unitTestLogic.addInfoStringArray(new String[]{test + " failed.", "Expected " + expected + ", but was " + actual});
    }

    /**
     * This method is used to notify the framework that a assertion failed.
     * It also may be used by the developers to produce a fail in some special condition.
     * It receives some identification parameters, used by the framework in the console fail report.
     *
     * @param test the identification of what failed.
     * @throws AssertionFailedException as result of a failed assertion.
     * @since JMUnit 1.0
     */
    public static final void fail(String test, float expected, float actual) throws AssertionFailedException {
        System.out.println(test + " failed.");
        System.out.println("Expected " + expected + ", but was " + actual);
        unitTestLogic.addInfoStringArray(new String[]{test + " failed.", "Expected " + expected + ", but was " + actual});
    }

    /**
     * This method is used to notify the framework that a assertion failed.
     * It also may be used by the developers to produce a fail in some special condition.
     * It receives some identification parameters, used by the framework in the console fail report.
     *
     * @param test the identification of what failed.
     * @throws AssertionFailedException as result of a failed assertion.
     * @since JMUnit 1.0
     */
    public static final void fail(String test, short expected, short actual) throws AssertionFailedException {
        System.out.println(test + " failed.");
        System.out.println("Expected " + expected + ", but was " + actual);
        unitTestLogic.addInfoStringArray(new String[]{test + " failed.", "Expected " + expected + ", but was " + actual});
        //fail();
    }

    /**
     * This method is used to notify the framework that a assertion failed.
     * It also may be used by the developers to produce a fail in some special condition.
     * It receives some identification parameters, used by the framework in the console fail report.
     *
     * @param test the identification of what failed.
     * @throws AssertionFailedException as result of a failed assertion.
     * @since JMUnit 1.0
     */
    public static final void fail(String test, long expected, long actual) throws AssertionFailedException {
        System.out.println(test + " failed.");
        System.out.println("Expected " + expected + ", but was " + actual);
        unitTestLogic.addInfoStringArray(new String[]{test + " failed.", "Expected " + expected + ", but was " + actual});
    }

    /**
     * This method is used to notify the framework that a assertion failed.
     * It also may be used by the developers to produce a fail in some special condition.
     * It receives some identification parameters, used by the framework in the console fail report.
     *
     * @param test the identification of what failed.
     * @throws AssertionFailedException as result of a failed assertion.
     * @since JMUnit 1.0
     */
    public static final void fail(String test, byte expected, byte actual) throws AssertionFailedException {
        System.out.println(test + " failed.");
        System.out.println("Expected " + expected + ", but was " + actual);
        unitTestLogic.addInfoStringArray(new String[]{test + " failed.", "Expected " + expected + ", but was " + actual});
    }

    /**
     * This method is used to notify the framework that a assertion failed.
     * It also may be used by the developers to produce a fail in some special condition.
     * It receives some identification parameters, used by the framework in the console fail report.
     *
     * @param test the identification of what failed.
     * @throws AssertionFailedException as result of a failed assertion.
     * @since JMUnit 1.0
     */
    public static final void fail(String test, int expected, int actual) throws AssertionFailedException {
        System.out.println(test + " failed.");
        System.out.println("Expected " + expected + ", but was " + actual);
        unitTestLogic.addInfoStringArray(new String[]{test + " failed.", "Expected " + expected + ", but was " + actual});
    }

    /**
     * This method is used to notify the framework that a assertion failed.
     * It also may be used by the developers to produce a fail in some special condition.
     * It receives some identification parameters, used by the framework in the console fail report.
     *
     * @param test the identification of what failed.
     * @throws AssertionFailedException as result of a failed assertion.
     * @since JMUnit 1.0
     */
    public static final void fail(String test, char expected, char actual) throws AssertionFailedException {
        System.out.println(test + " failed.");
        System.out.println("Expected " + expected + ", but was " + actual);
        unitTestLogic.addInfoStringArray(new String[]{test + " failed.", "Expected " + expected + ", but was " + actual});
    }

    /**
     * This method is used to notify the framework that a assertion failed.
     * It also may be used by the developers to produce a fail in some special condition.
     * It receives some identification parameters, used by the framework in the console fail report.
     *
     * @param test the identification of what failed.
     * @throws AssertionFailedException as result of a failed assertion.
     * @since JMUnit 1.0
     */
    public static final void fail(String test, boolean expected, boolean actual) throws AssertionFailedException {
        System.out.println(test + " failed.");
        System.out.println("Expected " + expected + ", but was " + actual);
        unitTestLogic.addInfoStringArray(new String[]{test + " failed.", "Expected " + expected + ", but was " + actual});
    }

    /**
     * This method is used to notify the framework that a assertion failed.
     * It also may be used by the developers to produce a fail in some special condition.
     * It receives some identification parameters, used by the framework in the console fail report.
     *
     * @param test the identification of what failed.
     * @throws AssertionFailedException as result of a failed assertion.
     * @since JMUnit 1.0
     */
    public static final void fail(String test, String expected, String actual) throws AssertionFailedException {
        System.out.println(test + " failed.");
        System.out.println("Expected " + expected + ", but was " + actual);
        unitTestLogic.addInfoStringArray(new String[]{test + " failed.", "Expected " + expected + ", but was " + actual});
    }

    /**
     * This method is used to notify the framework that a assertion failed.
     * It also may be used by the developers to produce a fail in some special condition.
     * It receives some identification parameters, used by the framework in the console fail report.
     *
     * @param test the identification of what failed.
     * @throws AssertionFailedException as result of a failed assertion.
     * @since JMUnit 1.0
     */
    public static final void fail(String test, Object expected, Object actual) throws AssertionFailedException {
        System.out.println(test + " failed.");
        System.out.println("Expected " + expected + ", but was " + actual);
        unitTestLogic.addInfoStringArray(new String[]{test + " failed.", "Expected " + expected + ", but was " + actual});
    }

    /**
     * This method is used to notify the framework that a assertion failed.
     * It also may be used by the developers to produce a fail in some special condition.
     *
     * @throws AssertionFailedException as result of a failed assertion.
     * @since JMUnit 1.0
     */
    public static final void fail() throws AssertionFailedException {
        throw new AssertionFailedException();
    }
}
