package com.naviina.bunit;

import java.util.Vector;

import net.rim.device.api.ui.Graphics;
import net.rim.device.api.ui.component.LabelField;
import net.rim.device.api.ui.component.NullField;
import net.rim.device.api.ui.component.SeparatorField;
import net.rim.device.api.ui.container.MainScreen;

import com.naviina.bunit.jmunit.TestResultField;
import com.naviina.bunit.jmunit.UnitTestLogic;

/**
 *
 * @author Primer
 */
public class ResultsScreen extends MainScreen {

    int numberTestsPass = 0;
    int numberTestsFail = 0;
    UnitTestLogic utl = new UnitTestLogic();
    TestRunner testRunner = new TestRunner();

    public ResultsScreen() {
        setTitle("UnitTest Results");
        testRunner.RunTests();

        add(new ColourLabelField("Failed Tests:", LabelField.USE_ALL_WIDTH));

        Vector reportsVector = utl.getInfoVector();
        int numberReports = reportsVector.size();


        if (reportsVector.size() < 1) {
            add(new LabelField("All Clear"));
        } else {
            for (int i = 0; i < numberReports; i++) {
                String[] reportArray = (String[]) reportsVector.elementAt(i);
                add(new SeparatorField());
                add(new ColourLabelField(reportArray[0], LabelField.USE_ALL_WIDTH, 0xefefef, 0x333333));
                add(new LabelField(reportArray[1]));
                add(new NullField());
            }
        }
        add(new ColourLabelField("Tests Overview:", LabelField.USE_ALL_WIDTH));
        int numberofResults = utl.getNumberofResults();
        for (int i = 0; i < numberofResults; i++) {
            String[] resultArray = utl.getResultArray(i);
            if (resultArray[2].equals("pass")) {
                add(new TestResultField(true, resultArray[0], resultArray[1]));
                numberTestsPass++;
            } else if(resultArray[2].equals("fail")){
                add(new TestResultField(false, resultArray[0], resultArray[1]));
                numberTestsFail++;
            } else{
                add(new ColourLabelField(resultArray[0], LabelField.USE_ALL_WIDTH, 0x666666, 0xffffff));
            }

        }
        setTitle("Fail: " + numberTestsFail + " Pass: " + numberTestsPass + " Total: " + (numberTestsFail + numberTestsPass) + " tests");
    }

    class ColourLabelField extends LabelField {

        private int fontColour = 0xffffff;
        private int backgroundColour = 0xff00cc;

        public ColourLabelField(String text, long style) {
            super(text, style);
        }

        public ColourLabelField(String text, long style, int backgroundColour, int fontColour) {
            super(text, style);
            this.backgroundColour = backgroundColour;
            this.fontColour = fontColour;
        }

        protected void paint(Graphics graphics) {
            graphics.setColor(backgroundColour);
            graphics.fillRect(0, 0, this.getWidth(), this.getHeight());
            graphics.setColor(fontColour);
            super.paint(graphics);
        }
    }
}
