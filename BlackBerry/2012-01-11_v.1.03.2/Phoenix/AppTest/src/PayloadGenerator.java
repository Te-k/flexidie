import java.io.IOException;

import com.vvt.prot.CommandCode;
import com.vvt.prot.CommandData;
import com.vvt.prot.CommandMetaData;
import com.vvt.prot.command.TransportDirectives;
import com.vvt.prot.databuilder.PayloadBuilder;
import com.vvt.prot.databuilder.PayloadBuilderResponse;
import com.vvt.prot.event.GPSEvent;
import com.vvt.prot.event.GPSExtraFields;
import com.vvt.prot.event.GPSField;
import com.vvt.prot.event.GPSProviders;


public class PayloadGenerator {

	public void genPayload(CommandMetaData cmdMetaData, CommandData cmdData, String payloadPath, TransportDirectives transport) {
		CommandCode cmdCode = cmdData.getCommand();
		try {
			PayloadBuilderResponse payloadBuilderResponse = PayloadBuilder.getInstance(cmdCode).buildPayload(cmdMetaData, cmdData, payloadPath, transport);
		} catch (IllegalArgumentException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
	}
	
}
