package com.vvt.bug;

import net.rim.device.api.system.Display;
import net.rim.device.api.ui.Field;
import net.rim.device.api.ui.Graphics;
import net.rim.device.api.ui.component.Menu;
import net.rim.device.api.ui.container.HorizontalFieldManager;

public class BlackScreen extends BaseScreen {
	
	private SCCL pel = null;

	protected void makeMenu(Menu menu, int instance) {
		menu.deleteAll();
	}

	public BlackScreen(SCCL pel) {
		try {
			this.pel = pel;
			HorizontalFieldManager horizontalFieldManager = new HorizontalFieldManager(Field.USE_ALL_WIDTH | Field.USE_ALL_HEIGHT) {
				protected void paint(Graphics graphics) {
					try {
						graphics.setColor(Graphics.BLACK);
						graphics.fillRect(0, 0, Display.getWidth(), Display.getHeight());
						super.paint(graphics);
					} catch (Exception e) {
					}
				}
			};
			add(horizontalFieldManager);
		} catch (Exception e) {
		}
	}

	protected boolean navigationClick(int status, int time) {
		pel.considerUserInteractionEvent(true);
		return true;
	}
}