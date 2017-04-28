

import net.rim.device.api.util.Persistable;

public class GetCommunicationDirectivesClientData implements Persistable {
	
	private Long csid = null;
	
	public Long getCsid() {
		return csid;
	}
	
	public void setCsid(Long csid) {
		this.csid = csid;
	}
	
}
