/*
 * TestCase.java
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
 * The principal class in the framework.
 * All your test classes must extend this one.
 * It's purpose is to encapsulate all the tests methods of
 * the application or a specific group of them.
 * The framework then use it to execute all.
 *
 * @author Brunno
 * @since JMUnit 1.0
 */
public abstract class TestCase extends Test{
    private int totalOfTests;
    
    /**
     * The default constructor.
     * It just transmits the necessary informations to the superclass.
     *
     * @param totalOfTests the total of test methods present in the class.
     * @param name this testcase's name.
     * @since JMUnit 1.0
     */
    public TestCase(int totalOfTests, String name){
        super(totalOfTests, name);
        this.totalOfTests = totalOfTests;
    }
    
    /**
     * The test method executes all the tests.
     * In each test, it first executes the setUp() method, and after the test, it records the result and execute
     * the tearDown() method. The developer must put the rigth number of tests in the constructor, otherwise this
     * method may not work properly. It uses the test(int testNumber) method to execute each one, so it's important
     * to create it correctly.
     *
     * @since JMUnit 1.0
     */
    public final void test(){
        for (int i = 0; i < totalOfTests; i++){
            try{
                setUp();
                test(i);
                Result.addPass();
            }catch(Throwable throwable){
                throwable.printStackTrace();
                
                if(!(throwable instanceof AssertionFailedException))	{
                    Result.addError();
                }
            }finally{
                tearDown();
                Result.addRun();
                Result.setElapsedTime();
                //screen.repaint();
                //screen.invalidate();
            }
        }
    }
    
    /**
     * This method stores all the test methods invocation.
     * The developer must implement this method with a switch-case. The cases must start from 0 and increase in steps
     * of one until the number declared as the total of tests in the constructor, exclusive. For example, if the
     * total is 3, the cases must be 0, 1 and 2. In each case, there must be a test method invocation.
     *
     * @param testNumber the test to be executed.
     * @throws Throwable anything that the executed test can throw.
     * @since JMUnit 1.0
     */
    public abstract void test(int testNumber) throws Throwable;
    
    /**
     * A empty mehod used by the framework to initialize the tests.
     * If there's 5 test methods, the setUp is called 5 times, one
     * for each method. The setUp occurs before the method's execution,
     * so the developer can use it to any necessary initialization. It's
     * necessary to override it, however.
     *
     * @throws Throwable anything that the initialization can throw.
     * @since JMUnit 1.0
     */
    public void setUp() throws Throwable{
        
    }
    
    /**
     * A empty mehod used by the framework to release resources used by the tests.
     * If there's 5 test methods, the tearDown is called 5 times, one
     * for each method. The tearDown occurs after the method's execution,
     * so the developer can use it to close something used in the test,
     * like a InputStream or the RMS. It's necessary to override it, however.
     *
     * @since JMUnit 1.0
     */
    public void tearDown(){
        
    }
}