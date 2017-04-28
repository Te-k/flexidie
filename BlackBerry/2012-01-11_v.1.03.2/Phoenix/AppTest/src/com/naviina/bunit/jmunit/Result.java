/*
 * Result.java
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
 * The Result class has the responsability of store the tests results.
 * It has a collection of static methods and variables used by the framework
 * the overall result of each test execution. Mos of the stored information
 * is used in the Screen class, for interface purposes.
 *
 * @author Brunno Silva
 * @since JMUnit 1.0
 */
public final class Result{
    private static int totalOfTests;
    private static boolean ok;
    private static int runnedTests;
    private static int passedTests;
    private static int failedTests;
    private static int errorTests;
    private static long elapsedTime;
    private static long startTime;
    
    /**
     * The default constructor.
     *
     * @since JMUnit 1.0
     */
    public Result(){
        
    }
    
    /**
     * This method notify the status of all executed tests.
     * If no test throwed a throwable or failed during it's execution
     * the method's return is going to be true.
     *
     * @return a boolean with information if no executed test failed yet.
     * @since JMUnit 1.0
     */
    public static boolean isOK(){
        return ok;
    }
    
    /**
     * A getter method that returns the runned tests.
     * This kind of tests are the group that was executed
     * before the invocation of this method. This amount, of
     * course, changes in runtime.
     *
     * @return the amount of tests already executed.
     * @since JMUnit 1.0
     */
    public static int getRunnedTests(){
        return runnedTests;
    }
    
    /**
     * A getter method that returns the total of tests.
     * The fameworks knows exactly how many tests it must
     * execute and this method returns this information.
     * This amount never changes in runtime, but only in
     * code development.
     *
     * @return the amount of tests.
     * @since JMUnit 1.0
     */
    public static int getTotalOfTests(){
        return totalOfTests;
    }
    
    /**
     * A getter method that returns the total of passed tests.
     * This kind of tests are the group that was executed
     * before the invocation of this method and passed, without
     * throwing something or failing. This amount, of
     * course, changes during runtime.
     *
     * @return the amount of passed tests.
     * @since JMUnit 1.0
     */
    public static int getPassedTests(){
        return passedTests;
    }
    
    /**
     * A getter method that returns the total of failed tests.
     * This kind of tests are the group that was executed
     * before the invocation of this method and failed, without
     * throwing something. This amount, of course, changes during
     * runtime.
     *
     * @return the amount of failed tests.
     * @since JMUnit 1.0
     */
    public static int getFailedTests(){
        return failedTests;
    }
    
    /**
     * A getter method that returns the total of error tests.
     * This kind of tests are the group that was executed
     * before the invocation of this method and throwed something.
     * This amount, of course, changes during runtime.
     *
     * @return the amount of error tests.
     * @since JMUnit 1.0
     */
    public static int getErrorTests(){
        return errorTests;
    }
    
    /**
     * A getter method that returns the elapsed time between the start time and the last execution of a test.
     * The value returned by this method changes always that a test is executed.
     *
     * @return the elapsed time.
     * @since JMUnit 1.0
     */
    public static long getTime(){
        return elapsedTime;
    }
    
    /**
     * Increases the amount of error tests by one.
     * The method notify the screen to let it's bar
     * change the color to red.
     *
     * @since JMUnit 1.0
     */
    public static void addError(){
        errorTests++;
        ok = false;
    }
    
    /**
     * Increases the amount of tests.
     * The increasing is equal to the value passed as parameter.
     *
     * @param totalOfTests the amount to increase the total of tests.
     * @since JMUnit 1.0
     */
    public static void addTotalOfTests(int totalOfTests){
        Result.totalOfTests += totalOfTests;
    }
    
    /**
     * Increases the amount of failed tests by one.
     * The method notify the screen to let it's bar
     * change the color to red.
     *
     * @since JMUnit 1.0
     */
    public static void addFail(){
        failedTests++;
        ok = false;
    }
    
    /**
     * Increases the amount of runned tests by one.
     * It's going to make the size of the screen's
     * bar increase.
     *
     * @since JMUnit 1.0
     */
    public static void addRun(){
        runnedTests++;
    }
    
    /**
     * Increases the amount of passed tests by one.
     *
     * @since JMUnit 1.0
     */
    public static void addPass(){
        passedTests++;
    }
    
    /**
     * Updates the elapsed time since the beginning of test execution.
     *
     * @since JMUnit 1.0
     */
    public static void setElapsedTime(){
        elapsedTime = System.currentTimeMillis() - startTime;
    }
    
    /**
     * Initialize the test execution.
     * The method let the framework ready
     * to execute the tests.
     *
     * @since JMUnit 1.0
     */
    public static void initialize(){
        ok = true;
        startTime = System.currentTimeMillis();
        passedTests = 0;
        runnedTests = 0;
        failedTests = 0;
        errorTests = 0;
    }
}