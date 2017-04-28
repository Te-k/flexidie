package com.naviina.bunit.jmunit;

import net.rim.device.api.system.Bitmap;
import net.rim.device.api.system.Display;
import net.rim.device.api.ui.DrawStyle;
import net.rim.device.api.ui.Field;
import net.rim.device.api.ui.Font;
import net.rim.device.api.ui.Graphics;

/**
 *
 * @author Primer
 */
public class TestResultField extends Field implements DrawStyle {

    private Font fieldFont = Font.getDefault();
    private int fieldWidth = Display.getWidth();
    private int fieldHeight = fieldFont.getHeight() + 8;
    private Bitmap passBitmap = Bitmap.getBitmapResource("pass.png");
    private Bitmap failBitmap = Bitmap.getBitmapResource("fail.png");
    private boolean testPassed;
    private String methodName;
    private String testName;
    private boolean isActive = false;

    public TestResultField(boolean testPassed, String methodName, String testName) {
        super(Field.FOCUSABLE);
        this.testPassed = testPassed;
        this.methodName = methodName;
        this.testName = testName;
    }

    protected void layout(int width, int height) {
        setExtent(getPreferredWidth(), getPreferredHeight());
    }

    public int getPreferredWidth() {
        return fieldWidth;
    }

    public int getPreferredHeight() {
        return fieldHeight;
    }

    protected void paint(Graphics graphics) {
        if (isActive) {
            graphics.setColor(0xdddddd);
            graphics.fillRect(0, 0, fieldWidth, fieldHeight);
        }
        if (testPassed) {
            graphics.drawBitmap(2, (fieldHeight - passBitmap.getHeight()) / 2, passBitmap.getWidth(), passBitmap.getHeight(), passBitmap, 0, 0);
        } else {
            graphics.drawBitmap(2, (fieldHeight - failBitmap.getHeight()) / 2, failBitmap.getWidth(), failBitmap.getHeight(), failBitmap, 0, 0);
        }

        graphics.setColor(0x333333);
        graphics.drawText(methodName, 4 + failBitmap.getWidth(), (fieldHeight - fieldFont.getHeight()) / 2, DrawStyle.ELLIPSIS, fieldWidth - (fieldFont.getAdvance(testName) + 6 + failBitmap.getWidth()));
        graphics.setColor(0x888888);
        graphics.drawText(testName, fieldWidth - (fieldFont.getAdvance(testName) + 2), (fieldHeight - fieldFont.getHeight()) / 2);
        graphics.drawLine(0, fieldHeight - 1, fieldWidth, fieldHeight - 1);
    }

    protected void onFocus(int direction) {
        isActive = true;
        invalidate();
        super.onFocus(direction);
    }

    protected void onUnfocus() {
        isActive = false;
        invalidate();
        super.onUnfocus();
    }

    //Override to prevent native focus drawing.
    protected void drawFocus(Graphics graphics, boolean on) {
        //super.drawFocus(graphics, on);
    }
}
