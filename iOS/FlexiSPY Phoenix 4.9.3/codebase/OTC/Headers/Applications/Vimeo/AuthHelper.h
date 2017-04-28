/*
; @class AuthHelper : NSObject {
;     @property currentRequestOperation
;     ivar _currentRequestOperation
;     +isTextInputError:
;     -dealloc
;     -cancelCurrentRequest
;     -loginWithEmail:password:completionBlock:
;     -joinWithName:email:password:completionBlock:
;     -loginWithFacebook:
;     -joinWithFacebook:
;     -resetPasswordForEmail:completionBlock:
;     -logout
;     -facebookTokenWithCompletionBlock:
;     -.cxx_destruct
;     -currentRequestOperation
;     -setCurrentRequestOperation:
; }
*/

@interface AuthHelper : NSObject {
}

-(void)loginWithEmail:(id)arg1 password:(id) arg2 completionBlock:(id)arg3;
-(void)joinWithName:(id)arg1 email:(id)arg2 password:(id)arg3 completionBlock:(id)arg4;

// 6.0
-(void)loginWithEmail:(id)arg1 password:(id) arg2 analyticsOrigin:(id)arg3 completionBlock:(id)arg4;
-(void)joinWithName:(id)arg1 email:(id)arg2 password:(id)arg3 analyticsOrigin:(id)arg4 completionBlock:(id)arg5;
@end