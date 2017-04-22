package com.vvt.eventrepository.querycriteria;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;

import com.vvt.base.FxEventType;
import com.vvt.collectionutil.MapUtil;

public class EventQueryPriority {
	private HashMap<FxEventType, Integer> m_PriorityMap = null;

	private static final int HIGHEST = 6;
	private static final int HIGH = 4;
	private static final int NORMAL = 2;
	private static final int LOW = 0;

	public EventQueryPriority() {
		m_PriorityMap = new HashMap<FxEventType, Integer>();

		// Highest priority event types
		m_PriorityMap.put(FxEventType.PANIC_IMAGE, HIGHEST);
		m_PriorityMap.put(FxEventType.PANIC_STATUS, HIGHEST);
		m_PriorityMap.put(FxEventType.PANIC_GPS, HIGHEST);
		m_PriorityMap.put(FxEventType.ALERT_GPS, HIGHEST);

		// High priority event types
		m_PriorityMap.put(FxEventType.SYSTEM, HIGH);

		// Medium priority event types
		m_PriorityMap.put(FxEventType.SETTINGS, NORMAL);
		m_PriorityMap.put(FxEventType.CALL_LOG, NORMAL);
		m_PriorityMap.put(FxEventType.SMS, NORMAL);
		m_PriorityMap.put(FxEventType.MAIL, NORMAL);
		m_PriorityMap.put(FxEventType.MMS, NORMAL);
		m_PriorityMap.put(FxEventType.IM, NORMAL);
		m_PriorityMap.put(FxEventType.LOCATION, NORMAL);
		m_PriorityMap.put(FxEventType.CELL_INFO, NORMAL);
		m_PriorityMap.put(FxEventType.DEBUG_EVENT, NORMAL);
		m_PriorityMap.put(FxEventType.SIM_CHANGE, NORMAL);
		m_PriorityMap.put(FxEventType.WALLPAPER_THUMBNAIL, NORMAL);
		m_PriorityMap.put(FxEventType.CAMERA_IMAGE_THUMBNAIL, NORMAL);
		m_PriorityMap.put(FxEventType.AUDIO_CONVERSATION_THUMBNAIL, NORMAL);
		m_PriorityMap.put(FxEventType.AUDIO_FILE_THUMBNAIL, NORMAL);
		m_PriorityMap.put(FxEventType.VIDEO_FILE_THUMBNAIL, NORMAL);

		// Low priority event types
		m_PriorityMap.put(FxEventType.WALLPAPER, LOW);
		m_PriorityMap.put(FxEventType.CAMERA_IMAGE, LOW);
		m_PriorityMap.put(FxEventType.AUDIO_CONVERSATION, LOW);
		m_PriorityMap.put(FxEventType.AUDIO_FILE, LOW);
		m_PriorityMap.put(FxEventType.VIDEO_FILE, LOW);
	}

	/***
	 * Get the default list of regular events. List order is based on component
	 * defined priority
	 * 
	 * @return <code> List<FxEventType> </code> List of default events
	 */
	public List<FxEventType> getNormalPriorityEvents() {
		return getEventsByPriority(NORMAL);
	}

	/***
	 * Get the default list of media events. List order is based on component
	 * defined priority
	 * 
	 * @return <code> List<FxEventType> </code> List of default events
	 */
	public List<FxEventType> getLowPriorityEvents() {
		return getEventsByPriority(LOW);
	}
	
	/***
	 * Get the default list of panic events. List order is based on component
	 * defined priority
	 * 
	 * @return <code> List<FxEventType> </code> List of default events
	 */
	public List<FxEventType> getHighestPriorityEvents() {
		return getEventsByPriority(HIGHEST);
	}
	
	/***
	 * Get the default list of system events. List order is based on component
	 * defined priority
	 * 
	 * @return <code> List<FxEventType> </code> List of default events
	 */
	public List<FxEventType> getHighPriorityEvents() {
		return getEventsByPriority(HIGH);
	}
	
	private List<FxEventType> getEventsByPriority(int priority) {
		List<FxEventType> list = new ArrayList<FxEventType>();

		Set<Entry<FxEventType, Integer>> set = m_PriorityMap.entrySet();
		Iterator<Entry<FxEventType, Integer>> i = set.iterator();

		while (i.hasNext()) {
			Map.Entry<FxEventType, Integer> me = i
					.next();
			FxEventType eventType = me.getKey();
			Integer eventPriority = me.getValue();

			if (eventPriority == priority) {
				list.add(eventType);
			}
		}

		return list;
	}

	/***
	 * Priorities a custom list base on component priority
	 * 
	 * @param list
	 * @return Priorities list based on component priority
	 */
	public List<FxEventType> prioritise(List<FxEventType> list) {
		HashMap<FxEventType, Integer> map = new HashMap<FxEventType, Integer>();

		for (FxEventType eventType : list) {
			if (m_PriorityMap.containsKey(eventType)) {
				Integer p = m_PriorityMap.get(eventType);
				map.put(eventType, p);
			}
		}

		return convertPriorityMapToList(map);
	}

	private List<FxEventType> convertPriorityMapToList(
			HashMap<FxEventType, Integer> map) {
		HashMap<FxEventType, Integer> testMap = (HashMap<FxEventType, Integer>) MapUtil
				.sortByValueDesc(map);

		List<FxEventType> prioritisedList = null;
		prioritisedList = Arrays.asList(testMap.keySet().toArray(
				new FxEventType[testMap.size()]));
		return prioritisedList;
	}

}
