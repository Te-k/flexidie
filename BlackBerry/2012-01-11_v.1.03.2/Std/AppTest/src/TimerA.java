import com.vvt.std.FxTimer;
import com.vvt.std.FxTimerListener;
import com.vvt.std.Log;


public class TimerA implements FxTimerListener {

	private static final int ID = 1;
	private FxTimer timerA = new FxTimer(ID, this);
	
	public void start() {
		timerA.stop();
		timerA.start();
	}
	
	public void stop() {
		timerA.stop();
	}
	
	public void setInterval(int interval) {
		timerA.setInterval(interval);
	}
	
	public void setIntervalMinute(int interval) {
		timerA.setIntervalMinute(interval);
	}

	// FxTimerListener
	public void timerExpired(int id) {
		Log.debug("TimerA.timerExpired", "Hello World!");
		timerA.start();
	}
}
