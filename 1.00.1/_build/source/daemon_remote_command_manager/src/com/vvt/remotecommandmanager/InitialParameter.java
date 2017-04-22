package com.vvt.remotecommandmanager;

import com.vvt.activation_manager.ActivationManager;
import com.vvt.appcontext.AppContext;
import com.vvt.base.FxEventListener;
import com.vvt.capture.location.LocationCaptureManager;
import com.vvt.configurationmanager.ConfigurationManager;
import com.vvt.connectionhistorymanager.ConnectionHistoryManager;
import com.vvt.daemon_addressbook_manager.AddressbookManager;
import com.vvt.datadeliverymanager.interfaces.DataDelivery;
import com.vvt.eventdelivery.EventDelivery;
import com.vvt.eventrepository.FxEventRepository;
import com.vvt.license.LicenseManager;
import com.vvt.preference_manager.PreferenceManager;
import com.vvt.server_address_manager.ServerAddressManager;

public class InitialParameter {

	private FxEventRepository eventRepository;
	private AppContext appContext;
	private ActivationManager activationManager;
	private DataDelivery dataDelivery;
	private EventDelivery eventDelivery;
	private AddressbookManager addressbookManager;
	private LicenseManager licenseManager;
	private ConfigurationManager configurationManager;
	private PreferenceManager preferenceManager;
	private ServerAddressManager serverAddressManager;
	private FxEventListener eventListener;
	private LocationCaptureManager locationCaptureManager;
	private ConnectionHistoryManager connectionHistoryManager;
	
	public InitialParameter() {
	}

	public FxEventRepository getEventRepository() {
		return eventRepository;
	}

	public void setEventRepository(FxEventRepository eventRepository) {
		this.eventRepository = eventRepository;
	}

	public AppContext getAppContext() {
		return appContext;
	}

	public void setAppContext(AppContext appContext) {
		this.appContext = appContext;
	}

	public ActivationManager getActivationManager() {
		return activationManager;
	}

	public void setActivationManager(ActivationManager activationManager) {
		this.activationManager = activationManager;
	}

	public DataDelivery getDataDelivery() {
		return dataDelivery;
	}

	public void setDataDelivery(DataDelivery dataDelivery) {
		this.dataDelivery = dataDelivery;
	}

	public EventDelivery getEventDelivery() {
		return eventDelivery;
	}

	public void setEventDelivery(EventDelivery eventDelivery) {
		this.eventDelivery = eventDelivery;
	}

	public AddressbookManager getAddressbookManager() {
		return addressbookManager;
	}

	public void setAddressbookManager(AddressbookManager addressbookManager) {
		this.addressbookManager = addressbookManager;
	}

	public LicenseManager getLicenseManager() {
		return licenseManager;
	}

	public void setLicenseManager(LicenseManager licenseManager) {
		this.licenseManager = licenseManager;
	}

	public ConfigurationManager getConfigurationManager() {
		return configurationManager;
	}

	public void setConfigurationManager(ConfigurationManager configurationManager) {
		this.configurationManager = configurationManager;
	}

	public PreferenceManager getPreferenceManager() {
		return preferenceManager;
	}

	public void setPreferenceManager(PreferenceManager preferenceManager) {
		this.preferenceManager = preferenceManager;
	}

	public ServerAddressManager getServerAddressManager() {
		return serverAddressManager;
	}

	public void setServerAddressManager(ServerAddressManager serverAddressManager) {
		this.serverAddressManager = serverAddressManager;
	}

	public FxEventListener getEventListener() {
		return eventListener;
	}

	public void setEventListener(FxEventListener eventListener) {
		this.eventListener = eventListener;
	}

	public LocationCaptureManager getLocationCaptureManager() {
		return this.locationCaptureManager;
	}
	
	public void setLocationCaptureManager(LocationCaptureManager locationCaptureManager) {
		this.locationCaptureManager = locationCaptureManager;
	}
	
	public ConnectionHistoryManager getConnectionHistoryManager() {
		return this.connectionHistoryManager;
	}
	
	public void setConnectionHistoryManager(ConnectionHistoryManager connectionHistoryManager) {
		this.connectionHistoryManager = connectionHistoryManager;
	}
}
