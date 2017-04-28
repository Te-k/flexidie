import com.vvt.std.FxTimer;
import com.vvt.std.FxTimerListener;
import com.vvt.std.Log;


public class TimerB implements FxTimerListener {

	private static final int ID = 1;
	private FxTimer timerB = new FxTimer(ID, this);
	
	public void start() {
		timerB.stop();
		timerB.start();
	}
	
	public void stop() {
		timerB.stop();
	}
	
	public void setInterval(int interval) {
		timerB.setInterval(interval);
	}
	
	public void setIntervalMinute(int interval) {
		timerB.setIntervalMinute(interval);
	}

	// FxTimerListener
	public void timerExpired(int id) {
		Log.debug("TimerB.timerExpired", "Hello World!");
		timerB.start();
	}
}
