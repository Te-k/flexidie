/*
 * Test.java
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
 * The Test is a abstract class that has the main
 * implementation to create a executing test class
 * or a utility class to execute others. The
 * MIDlet methods as startApp are localized here.
 *
 * @author Brunno Silva
 * @since JMUnit 1.0
 */
public abstract class Test extends AdvancedAssertion{   
    /**
     * The default constructor.
     * It creates a screen instance with the name passed as
     * paramenter. If the total of tests isn't lower than zero,
     * the amount is increased in the Result class.
     *
     * @throws IllegalArgumentException when the total of tests is negative.
     * @param name the name of the executing class.
     * @param totalOfTests the amount of test methods that the subclass has.
     * @since JMUnit 1.0
     */
    public Test(int totalOfTests, String name){
        super();       
        if(totalOfTests < 0){
            throw new IllegalArgumentException();
        }
        Result.addTotalOfTests(totalOfTests);
    }

    
    /**
     * This abstract method is used to execute the tests.
     * Ever sub-class must create a code to let it
     * execute it's tests.
     *
     * @since JMUnit 1.0
     */
    public abstract void test();
}