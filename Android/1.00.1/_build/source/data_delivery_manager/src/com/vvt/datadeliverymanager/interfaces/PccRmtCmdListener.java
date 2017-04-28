package com.vvt.datadeliverymanager.interfaces;

import java.util.List;

import com.vvt.phoenix.prot.command.response.PCC;

public interface PccRmtCmdListener {
	public void onReceivePCC(List<PCC> pcc);
}
