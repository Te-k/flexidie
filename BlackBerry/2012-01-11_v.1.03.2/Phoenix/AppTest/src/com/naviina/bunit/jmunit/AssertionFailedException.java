/*
 * AssertionFailedException.java
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
 * A sub-class of Exception used by the framework to manage a fail in a assertion.
 * When a assertion goes wrong, the framework throws a AssertionFailedException
 * to automatic update the Result object about this new fail. The amount of failed
 * tests increase by one and the JMUnit screen's bar turn red. Also, the framework
 * uses the exception to get information about which test failed, printing the data
 * in the console, so the mobile application developer can identify the problem.
 *
 * @author Brunno Silva
 * @since JMUnit 1.0
 */
public final class AssertionFailedException extends Exception{
    /**
     * The default constructor.
     * It increases the amount of failed tests in the final result.
     *
     * @since JMUnit 1.0
     */
    public AssertionFailedException(){
        System.out.println("result.addfail() in assertionfailexception.java");
        Result.addFail();
    }
}