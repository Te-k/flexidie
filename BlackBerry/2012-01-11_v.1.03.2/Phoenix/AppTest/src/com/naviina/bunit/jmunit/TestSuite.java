/*
 * TestSuite.java
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

import java.util.Vector;

/**
 * The TestSuite class is responsible for execute many TestCases.
 * As it extends Test, it can be used as a MIDlet in a simulator. To use it, it's necessary to create a subclass
 * with a super() declaration in the constructor. The method add(TestCase testCase) must be used in the constructor
 * of the subclass, adding the TestCases objects that are necessary to be runned. When everthing is coded, the
 * TestSuite can be used in the simulator.
 *
 * @author Brunno Silva
 * @since JMUnit 1.0
 */
public class TestSuite extends Test {
    private Node pointer;
    private Node first;
    
    /**
     * The default constructor.
     * As such TestSuite can be added to MIDlet list as is and it will take
     * list of classes to test from JMUnitTestClasses property.
     *
     * @param name the name of the TestSuite.
     * @since JMUnit 1.0
     */
    public TestSuite() {
        super(0,"Default test suite");
        //String prop=getAppProperty("JMUnitTestClasses");
        String prop="";
        String[] classes;
        
        if (prop!=null && !prop.equals("")) {
            classes=parseTestClassProperty(prop);
            Object clazz;
            
            for (int i=0;i<classes.length;i++) {
                try {
                    this.add((TestCase) Class.forName(classes[i]).newInstance());
                    System.out.println("clazz: "+classes[i]);
                } catch (Exception e) {
                    this.add(new EmptyTestCase(e));
                    System.out.println(e.getMessage());
                    e.printStackTrace();
                }
            }
        }
    }
    
    /**
     *
     * It must be called by the subclass constructor with a name parameter. It's also responsability of the
     * subclass to add TestCase objects to be executed in it's constructor.
     *
     * @param name the name of the TestSuite.
     * @since JMUnit 1.0
     */
    public TestSuite(String name) {
        super(0, name);
    }
    
    private String[] parseTestClassProperty(String property) {
        final String delimiter=" ";
        
        Vector classes=new Vector();
        
        while (property.length()>0) {
            int i=property.indexOf(delimiter);
            if (i>0) {
                classes.addElement(property.substring(0,i));
                property=property.substring(property.indexOf(delimiter)+1);
            } else {
                classes.addElement(property);
                property="";
            }
        }
        
        String[] result=new String[classes.size()];
        for (int i=0;i<classes.size();i++) {
            result[i]=(String) classes.elementAt(i);
            System.out.println("result "+i+": "+result[i]);
        }
        
        return result;
    }
    
    /**
     * The purpose of this method is store TestCases.
     * It uses a simple linkedlist to store them during runtime.
     *
     * @param testCase the TestCase to be added.
     * @since JMUnit 1.0
     */
    public final void add(TestCase testCase) {     
        if(first == null) {
            first = new Node(testCase);
        } else {
            goFirst();
            
            while(hasNext()) {
                next();
            }
            
            pointer.setNext(new Node(testCase));
        }
    }
    
    /**
     * The test method executes all the TestCases stored by the add method.
     *
     * @since JMUnit 1.0
     */
    public final void test() {
        goFirst();
        
        while(hasNext()) {
            next().test();
        }
    }
    
    private final void goFirst() {
        pointer = null;
    }
    
    private final Node next() {
        if(pointer == null) {
            pointer = first;
            return first;
        }
        
        pointer = pointer.getNext();
        return pointer;
    }
    
    private final boolean hasNext() {
        return pointer == null ? true : pointer.getNext() != null;
    }
    
    private class Node {
        private TestCase testCase;
        private Node next;
        
        public Node(TestCase testCase) {
            this.testCase = testCase;
        }
        
        public void setNext(Node node) {
            next = node;
        }
        
        public Node getNext() {
            return next;
        }
        
        public void test() {
            testCase.test();
        }
    }
    
    private class EmptyTestCase extends TestCase {
        
        private Exception e;
        
        public EmptyTestCase(Exception e) {
            super(1,"Empty Test");
            this.e=e;
        }
        
        public void test(int testNumber) throws Throwable {
            throw this.e;
        }
    }
}
