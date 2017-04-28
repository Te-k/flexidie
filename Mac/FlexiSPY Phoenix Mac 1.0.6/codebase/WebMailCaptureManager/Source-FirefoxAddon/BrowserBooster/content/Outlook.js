var EXPORTED_SYMBOLS = ["getIncomingOutlookThread", "isOutlookHasReadingPane", "isOutlookSendButtonInFocus", "getOutgoingOutlookThread"];

//<Method5>
function getIncomingOutlookThread(document) {
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
}
//</Method5>

//<Method6>
function isOutlookHasReadingPane(document) {
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
}
//</Method6>

//<Method7>
function isOutlookSendButtonInFocus(document) {
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
}
//</Method7>

//<Method8>
function getOutgoingOutlookThread(document) {
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
}
//</Method8>
