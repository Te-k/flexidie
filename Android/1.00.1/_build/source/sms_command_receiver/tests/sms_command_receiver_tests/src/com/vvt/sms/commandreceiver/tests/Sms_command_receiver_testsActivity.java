package com.vvt.sms.commandreceiver.tests;

import android.app.Activity;
import android.os.Bundle;
//import android.widget.TextView;

//import com.vvt.smscommandreceiver.SmsCommand;
//import com.vvt.smscommandreceiver.SmsCommandListener;
//import com.vvt.smscommandreceiver.SmsCommandReceiver;

public class Sms_command_receiver_testsActivity extends Activity {

//	private TextView mTextView;  
//
//	@SuppressWarnings("unused")
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.main);

//		mTextView = (TextView)findViewById(R.id.textView);

		
		// Construct the AppContext
		
//		SmsCommandReceiver smsCommandReceiver = new SmsCommandReceiver();
//
//		try {
//			smsCommandReceiver.register(smsCommandListener);
//
//		} catch (FxNullNotAllowedException e) {
//			e.printStackTrace();
//		}

	}
//	
//	@SuppressWarnings("unused")
//	private SmsCommandListener smsCommandListener = new SmsCommandListener() {
//		
//		@Override
//		public void onSmsCommandReceived(final SmsCommand smsCommand) {
//			Sms_command_receiver_testsActivity.this.runOnUiThread(new Runnable() {
//				
//				@Override
//				public void run() {
//					StringBuilder builder = new StringBuilder();
//					builder.append("======= onReceive =======");
//					builder.append("\n");
//					builder.append(String.format("SenderNumber 	: %s", smsCommand.getSenderNumber()));
//					builder.append("\n");
//					builder.append(String.format("SmsMessage 	: %s", smsCommand.getMessage()));
//					builder.append("\n");
//					builder.append("======= ======= =======");
//					builder.append("\n");
//					builder.append(mTextView.getText());
//					builder.append("\n");
//					mTextView.setText(builder.toString());
//				}
//			});
//			
//			
//		}
//	};
}