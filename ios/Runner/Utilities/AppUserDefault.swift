



import Foundation

class AppUserDefault {
    
    
    //access-token
    class func getAccessToken()-> String?{
        return UserDefaults.standard.string(forKey: "access-token")
    }
    
    class func setAccessToken(_ phone: String) {
        UserDefaults.standard.set(phone, forKey: "access-token")
        UserDefaults.standard.synchronize()
    }
    
    
    
    //phone
    class func getPhone()-> String?{
        return UserDefaults.standard.string(forKey: "phone")
    }
    
    class func setPhone(_ phone: String) {
        UserDefaults.standard.set(phone, forKey: "phone")
        UserDefaults.standard.synchronize()
    }
    
    //id
    class func getUserID()-> Int?{
        return UserDefaults.standard.integer(forKey: "user_id")
    }
    
    class func setUserID(_ userID: Int) {
        UserDefaults.standard.set(userID, forKey: "user_id")
        UserDefaults.standard.synchronize()
    }
    

    //Selected Language
    class func getSelectedLanguage()-> String?{
        return UserDefaults.standard.string(forKey: "selected_language")
    }
    
    class func setSelectedLanguage(_ language: String) {
        UserDefaults.standard.set(language, forKey: "selected_language")
        UserDefaults.standard.synchronize()
    }
    
    
    //Selected museum
    class func getSelectedMuseum()-> String?{
        return UserDefaults.standard.string(forKey: "selected_museum")
    }
    
    class func setSelectedMuseum(_ museum: String) {
        UserDefaults.standard.set(museum, forKey: "selected_museum")
        UserDefaults.standard.synchronize()
    }
    
    
    
    //Selected Mode
    class func getSelectedSpeed()-> String?{
        return UserDefaults.standard.string(forKey: "selected_speed")
    }
    
    class func setSelectedSpeed(_ speed: String) {
        UserDefaults.standard.set(speed, forKey: "selected_speed")
        UserDefaults.standard.synchronize()
    }
    
    
    //Selected Mode
    class func getSelectedMode()-> String?{
        return UserDefaults.standard.string(forKey: "selected_mode")
    }
    
    class func setSelectedMode(_ modeString: String) {
        UserDefaults.standard.set(modeString, forKey: "selected_mode")
        UserDefaults.standard.synchronize()
    }
    
    //Subscription Plan
    class func getSubPlan()-> String?{
        return UserDefaults.standard.string(forKey: "sub_plan")
    }
    
    class func setSubPlan(_ plan: String) {
        UserDefaults.standard.set(plan, forKey: "sub_plan")
        UserDefaults.standard.synchronize()
    }
    
    //is Indvidual
    class func getSubPlanStatus()-> Bool{
        return UserDefaults.standard.bool(forKey: "sub_plan_status")
    }
    
    class func setSubPlanStatus(_ isSubscribed: Bool) {
        UserDefaults.standard.set(isSubscribed, forKey: "sub_plan_status")
        UserDefaults.standard.synchronize()
    }
    
    //is Background Mode
    class func getIsBackgroundMode()-> Bool{
        return UserDefaults.standard.bool(forKey: "is_background_mode")
    }
    
    class func setIsBackgroundMode(_ isBackground: Bool) {
        UserDefaults.standard.set(isBackground, forKey: "is_background_mode")
        UserDefaults.standard.synchronize()
    }

    //is Chat Mode BG Enabled
    class func getIsChatMode()-> Bool{
        return UserDefaults.standard.bool(forKey: "is_chat_mode")
    }
    
    class func setIsChatMode(_ isChatMode: Bool) {
        UserDefaults.standard.set(isChatMode, forKey: "is_chat_mode")
        UserDefaults.standard.synchronize()
    }
    
    
    //is logged in
    class func getIsLoggedIn()-> Bool{
        return UserDefaults.standard.bool(forKey: "logged_in")
    }
    
    class func setIsLoggedIn(_ isLoggedIn: Bool) {
        UserDefaults.standard.set(isLoggedIn, forKey: "logged_in")
        UserDefaults.standard.synchronize()
    }
    
    
    class func getIsSoundOn()-> Bool{
        return UserDefaults.standard.bool(forKey: "processsound_on")
    }
    
    class func setIsSoundOn(_ isLoggedIn: Bool) {
        UserDefaults.standard.set(isLoggedIn, forKey: "processsound_on")
        UserDefaults.standard.synchronize()
    }
    
    class func getIsFirstTime()-> Bool{
        return UserDefaults.standard.bool(forKey: "s_first_time")
    }
    
    class func setIsFirstTime(_ isFirstTime: Bool) {
        UserDefaults.standard.set(isFirstTime, forKey: "s_first_time")
        UserDefaults.standard.synchronize()
    }

    //user Id
    class func getUserId()-> String?{
        return UserDefaults.standard.string(forKey: "user_id")
    }
    
    class func setUserId(_ userId: String) {
        UserDefaults.standard.set(userId, forKey: "user_id")
        UserDefaults.standard.synchronize()
    }
    
    
    //Session Id
    class func getSessionId()-> String?{
        return UserDefaults.standard.string(forKey: "session_id")
    }
    
    class func setSessionId(_ sessionID: String) {
        UserDefaults.standard.set(sessionID, forKey: "session_id")
        UserDefaults.standard.synchronize()
    }

}
