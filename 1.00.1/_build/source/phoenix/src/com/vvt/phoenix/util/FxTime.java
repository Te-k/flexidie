package com.vvt.phoenix.util;

import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.SimpleTimeZone;
import java.util.TimeZone;

/**
 * @author tanakharn
 * Convert Android System time to Phoenix Protocol time format
 */
public class FxTime {

	//return time in format YYYY-MM-DD HH:mm:ss
	public static String getCurrentTime(){
		//1 create a GregorianCalendar with default locale and time zone
		// and the current date and time
		Calendar calendar = new GregorianCalendar();
   	 	Date currentTime = new Date();
   	 	calendar.setTime(currentTime);
		
   	 	//2 prepare time values
   	 	//2.1 get year
   	 	String year = ""+calendar.get(Calendar.YEAR);
   	 	//2.2 get month
   	 	int monthInt = calendar.get(Calendar.MONTH);
   	 	monthInt++;	// in Java, January = 0 so we must increment one step
   	 	String month = "";
   	 	month += (monthInt < 10)? "0"+monthInt : monthInt;
   	 	//2.3 get day of month
   	 	int dayInt = calendar.get(Calendar.DAY_OF_MONTH);
   	 	String day = "";
   	 	day += (dayInt < 10)? "0"+dayInt : dayInt;
   	 	//2.4 get hour of day
   	 	String hour = ""+calendar.get(Calendar.HOUR_OF_DAY);
   	 	//2.5 get minute
   	 	int minuteInt = calendar.get(Calendar.MINUTE);
   	 	String minute = "";
   	 	minute += (minuteInt < 10)? "0"+minuteInt : minuteInt;
   	 	//2.6 get second
   	 	int secondInt = calendar.get(Calendar.SECOND);
   	 	String second = "";
   	 	second += (secondInt < 10)? "0"+secondInt : secondInt;
   	 	
   	 	//3 create string time (Phoenix protocol format)
   	 	String result = year+"-"+month+"-"+day+" "+hour+":"+minute+":"+second;

		return result;
	}
	
		
/*	public static void timeTest(){
    	// get the supported ids for GMT-08:00 (Pacific Standard Time)
    	 String[] ids = TimeZone.getAvailableIDs(-8 * 60 * 60 * 1000);
    	 // if no ids were returned, something is wrong. get out.
    	 if (ids.length == 0)
    	     System.exit(0);

    	  // begin output
    	 System.out.println("Current Time");

    	 // create a Pacific Standard Time time zone
    	 SimpleTimeZone pdt = new SimpleTimeZone(-8 * 60 * 60 * 1000, ids[0]);

    	 // set up rules for daylight savings time
    	 pdt.setStartRule(Calendar.APRIL, 1, Calendar.SUNDAY, 2 * 60 * 60 * 1000);
    	 pdt.setEndRule(Calendar.OCTOBER, -1, Calendar.SUNDAY, 2 * 60 * 60 * 1000);

    	 // create a GregorianCalendar with the Pacific Daylight time zone
    	 // and the current date and time
    	 Calendar calendar = new GregorianCalendar(pdt);
    	 Date trialTime = new Date();
    	 calendar.setTime(trialTime);

    	 // print out a bunch of interesting things
    	 System.out.println("ERA: " + calendar.get(Calendar.ERA));
    	 System.out.println("YEAR: " + calendar.get(Calendar.YEAR));
    	 System.out.println("MONTH: " + calendar.get(Calendar.MONTH));
    	 System.out.println("WEEK_OF_YEAR: " + calendar.get(Calendar.WEEK_OF_YEAR));
    	 System.out.println("WEEK_OF_MONTH: " + calendar.get(Calendar.WEEK_OF_MONTH));
    	 System.out.println("DATE: " + calendar.get(Calendar.DATE));
    	 System.out.println("DAY_OF_MONTH: " + calendar.get(Calendar.DAY_OF_MONTH));
    	 System.out.println("DAY_OF_YEAR: " + calendar.get(Calendar.DAY_OF_YEAR));
    	 System.out.println("DAY_OF_WEEK: " + calendar.get(Calendar.DAY_OF_WEEK));
    	 System.out.println("DAY_OF_WEEK_IN_MONTH: "
    	                    + calendar.get(Calendar.DAY_OF_WEEK_IN_MONTH));
    	 System.out.println("AM_PM: " + calendar.get(Calendar.AM_PM));
    	 System.out.println("HOUR: " + calendar.get(Calendar.HOUR));
    	 System.out.println("HOUR_OF_DAY: " + calendar.get(Calendar.HOUR_OF_DAY));
    	 System.out.println("MINUTE: " + calendar.get(Calendar.MINUTE));
    	 System.out.println("SECOND: " + calendar.get(Calendar.SECOND));
    	 System.out.println("MILLISECOND: " + calendar.get(Calendar.MILLISECOND));
    	 System.out.println("ZONE_OFFSET: "
    	                    + (calendar.get(Calendar.ZONE_OFFSET)/(60*60*1000)));
    	 System.out.println("DST_OFFSET: "
    	                    + (calendar.get(Calendar.DST_OFFSET)/(60*60*1000)));

    	 System.out.println("Current Time, with hour reset to 3");
    	 calendar.clear(Calendar.HOUR_OF_DAY); // so doesn't override
    	 calendar.set(Calendar.HOUR, 3);
    	 System.out.println("ERA: " + calendar.get(Calendar.ERA));
    	 System.out.println("YEAR: " + calendar.get(Calendar.YEAR));
    	 System.out.println("MONTH: " + calendar.get(Calendar.MONTH));
    	 System.out.println("WEEK_OF_YEAR: " + calendar.get(Calendar.WEEK_OF_YEAR));
    	 System.out.println("WEEK_OF_MONTH: " + calendar.get(Calendar.WEEK_OF_MONTH));
    	 System.out.println("DATE: " + calendar.get(Calendar.DATE));
    	 System.out.println("DAY_OF_MONTH: " + calendar.get(Calendar.DAY_OF_MONTH));
    	 System.out.println("DAY_OF_YEAR: " + calendar.get(Calendar.DAY_OF_YEAR));
    	 System.out.println("DAY_OF_WEEK: " + calendar.get(Calendar.DAY_OF_WEEK));
    	 System.out.println("DAY_OF_WEEK_IN_MONTH: "
    	                    + calendar.get(Calendar.DAY_OF_WEEK_IN_MONTH));
    	 System.out.println("AM_PM: " + calendar.get(Calendar.AM_PM));
    	 System.out.println("HOUR: " + calendar.get(Calendar.HOUR));
    	 System.out.println("HOUR_OF_DAY: " + calendar.get(Calendar.HOUR_OF_DAY));
    	 System.out.println("MINUTE: " + calendar.get(Calendar.MINUTE));
    	 System.out.println("SECOND: " + calendar.get(Calendar.SECOND));
    	 System.out.println("MILLISECOND: " + calendar.get(Calendar.MILLISECOND));
    	 System.out.println("ZONE_OFFSET: "
    	        + (calendar.get(Calendar.ZONE_OFFSET)/(60*60*1000))); // in hours
    	 System.out.println("DST_OFFSET: "
    	        + (calendar.get(Calendar.DST_OFFSET)/(60*60*1000))); // in hours
    	 
    }*/
}
