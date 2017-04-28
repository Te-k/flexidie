package com.fx.dalvik.activation;

public class ActivationManager {

	public static enum Status { ACTIVATED, DEACTIVATED };
	
	private ActivationInfo mActivationInfo;
	
//	private DefaultActivation mDefaultActivation;
//	private AutoActivation mAutoActivation;
	
	public ActivationManager(ActivationInfo activationInfo) {
		mActivationInfo = activationInfo;
	}
	
	/**
	 * Default activation. Require Activation Code.
	 */
	public ActivationResponse activateProduct(String activationCode) {
		DefaultActivation defaultActivation = null;
		defaultActivation = new DefaultActivation(mActivationInfo);
		
		return defaultActivation.activateProduct(activationCode);
	}
	
	/**
	 * Default deactivation. Require Activation Code.
	 */
	public ActivationResponse deactivateProduct(String activationCode) {
		DefaultActivation defaultActivation = null;
		defaultActivation = new DefaultActivation(mActivationInfo);
		
		return defaultActivation.deactivateProduct(activationCode);
	}
	
//	/**
//	 * Activate product using Automatic Activation Protocol.
//	 * Activation Code is not required.
//	 */
//	public ActivationResponse autoActivateProduct() {
//		mAutoActivation = new AutoActivation(mActivationInfo);
//		return mAutoActivation.activateProduct();
//	}
//	
//	/**
//	 * Deactivate product using Automatic Activation Protocol.
//	 * Activation Code is not required.
//	 */
//	public ActivationResponse autoDeactivateProduct(String activationCode) {
//		mAutoActivation = new AutoActivation(mActivationInfo);
//		return mAutoActivation.deactivateProduct(activationCode);
//	}
	
}
