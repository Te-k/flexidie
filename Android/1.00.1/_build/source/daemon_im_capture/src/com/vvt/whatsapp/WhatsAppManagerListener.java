package com.vvt.whatsapp;

public interface WhatsAppManagerListener
{
    public void onApkFileChange(boolean isNewinstallOrDelete);
    public void onDatabaseFolderChange(boolean isCreate);
 
}
