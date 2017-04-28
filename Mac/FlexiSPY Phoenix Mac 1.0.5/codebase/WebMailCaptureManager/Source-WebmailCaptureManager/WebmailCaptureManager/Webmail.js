//
//  Webmail.js
//  WebmailCaptureManager
//
//  Created by Makara Khloth on 11/7/16.
//

/*****************************************************************************************************
 **** Please use single quotes for string otherwise it will confuse with Objective-C in format method
 *****************************************************************************************************/

//<Method1>
function getYahooThread() {
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
} getYahooThread();
//</Method1>

//<Method2>
function isSendButtonInFocus() {
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
} isSendButtonInFocus();
//</Method2>

//<Method3>
function getYahooThreadBasic() {
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
        subject = subj.value;
        
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
} getYahooThreadBasic();
//</Method3>

//<Method4>
function isSendButtonInFocusBasic() {
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
} isSendButtonInFocusBasic();
//</Method4>
