

import com.vvt.prot.CommandResponse;

public interface PhoenixProtocolListener {
	public void onSuccess(CommandResponse response);
	public void onError(String message);
}
