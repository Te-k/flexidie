/*
 * JMUnit.java
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
 * A framework's utility class.
 * It has only the purpose of have some static methods that may help
 * other classes. The methods stay here for organization reasons.
 *
 * @author Brunno Silva
 * @since JMUnit 1.0
 */
public final class JMUnit{
    /**
     * A method that returns the current verison of the framework.
     * The String doesn't return only numerics characters, it also
     * brings the preffix "JMUnit ", for example, if the version of
     * the framework is 1.9, this method returns "JMUnit 1.9".
     *
     * @return the current version of the framework
     * @since JMUnit 1.0
     */
    public static String getVersion(){
        return "JMUnit 1.0";
    }
}