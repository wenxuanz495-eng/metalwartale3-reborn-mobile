package com.superalloy.sasave;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREExtension;

public final class SasaveExtension implements FREExtension {
    public void initialize() {}
    public FREContext createContext(String contextType) { return new SasaveContext(); }
    public void dispose() {}
}
