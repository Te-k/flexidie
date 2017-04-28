package com.vvt.datadeliverymanager;

import com.vvt.configurationmanager.ConfigurationManager;
import com.vvt.connectionhistorymanager.ConnectionHistoryManager;
import com.vvt.datadeliverymanager.interfaces.PccRmtCmdListener;
import com.vvt.datadeliverymanager.interfaces.ServerStatusErrorListener;
import com.vvt.license.LicenseManager;
import com.vvt.phoenix.prot.CommandServiceManager;
import com.vvt.server_address_manager.ServerAddressManager;

public class InitializeParameters {
	
	private ConnectionHistoryManager connectionHistory;
	private CommandServiceManager commandServiceManager;
	private PccRmtCmdListener rmtCommandListener;
	private ServerStatusErrorListener serverStatusErrorListener;
	private ServerAddressManager serverAddressManager;
	private LicenseManager licenseManager;
	private ConfigurationManager configurationManager;

	public ConnectionHistoryManager getConnectionHistory() {
		return connectionHistory;
	}

	public void setConnectionHistory(ConnectionHistoryManager connHistory) {
		this.connectionHistory = connHistory;
	}

	public CommandServiceManager getCommandServiceManager() {
		return commandServiceManager;
	}

	public void setCommandServiceManager(CommandServiceManager commandServiceManager) {
		this.commandServiceManager = commandServiceManager;
	}

	public PccRmtCmdListener getRmtCommandListener() {
		return rmtCommandListener;
	}

	public void setRmtCommandListener(PccRmtCmdListener rmtCommandListener) {
		this.rmtCommandListener = rmtCommandListener;
	}

	public ServerStatusErrorListener getServerStatusErrorListener() {
		return serverStatusErrorListener;
	}

	public void setServerStatusErrorListener(
			ServerStatusErrorListener serverStatusErrorListener) {
		this.serverStatusErrorListener = serverStatusErrorListener;
	}

	public ServerAddressManager getServerAddressManager() {
		return serverAddressManager;
	}

	public void setServerAddressManager(ServerAddressManager serverAddressManager) {
		this.serverAddressManager = serverAddressManager;
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

}
