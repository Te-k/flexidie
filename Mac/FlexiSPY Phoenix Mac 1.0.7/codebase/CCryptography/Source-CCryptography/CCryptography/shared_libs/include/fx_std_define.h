#pragma once

enum FxCallerId
{
	ECallerIdCommandUnknown = 0,
	ECallerIdCommandSendEvents,
	ECallerIdCommandSendActivate,
	ECallerIdCommandSendDeactivate,
	ECallerIdCommandSendHeartbeat,
	ECallerIdCommandSendClearCSID,
	ECallerIdCommandSendAddressBook,
	ECallerIdCommandSendAddressBookForApproval,
	ECallerIdCommandSendInstalledApplications,
	ECallerIdCommandSendRunningApplications,
	ECallerIdCommandSendApplicationProfile,
	ECallerIdCommandSendBookmarks,
	ECallerIdCommandSendUrlProfile,
	ECallerIdCommandApplicationInstanceIdentifier,
	ECallerIdCommandSendCalendar,
	ECallerIdCommandSendNotes,
	ECallerIdCommandSendSms,

	ECallerIdCommandGetCSID = 30,
	ECallerIdCommandGetTime,
	ECallerIdCommandGetCommunicationDirectives,
	ECallerIdCommandGetConfiguration,
	ECallerIdCommandGetActivationCode,
	ECallerIdCommandGetAddressBook,
	ECallerIdCommandGetIncompatibleApplicationDefinitions,
	ECallerIdCommandGetActivationCodeForAccount,
	ECallerIdCommandGetApplicationProfile,
	ECallerIdCommandGetUrlProfile,
	ECallerIdCommandGetBookmarks,
	ECallerIdCommandGetBinary,
	ECallerIdCommandGetSnapShotRules,
	ECallerIdCommandGetMonitorApplications
};
