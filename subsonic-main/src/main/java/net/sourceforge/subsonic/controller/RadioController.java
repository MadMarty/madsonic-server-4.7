package net.sourceforge.subsonic.controller;

import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import net.sourceforge.subsonic.service.MediaFileService;
import net.sourceforge.subsonic.service.SecurityService;
import net.sourceforge.subsonic.service.SettingsService;

import net.sourceforge.subsonic.domain.User;
import net.sourceforge.subsonic.domain.UserSettings;

import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.ParameterizableViewController;

/**
 * Controller for the genre radio.
 *
 */
public class RadioController extends ParameterizableViewController {

    private SettingsService settingsService;
    private MediaFileService mediaFileService;
    private SecurityService securityService;    

    protected ModelAndView handleRequestInternal(HttpServletRequest request, HttpServletResponse response) throws Exception {

		Map<String, Object> map = new HashMap<String, Object>();

        User user = securityService.getCurrentUser(request);
        UserSettings userSettings = settingsService.getUserSettings(user.getUsername());
		
        int userGroupId = securityService.getCurrentUserGroupId(request);        
        
		map.put("genres", mediaFileService.getGenres(userGroupId));
        map.put("musicFolders", settingsService.getAllMusicFolders(userGroupId));
        map.put("customScrollbar", userSettings.isCustomScrollbarEnabled()); 		

        ModelAndView result = super.handleRequestInternal(request, response);
        result.addObject("model", map);

        return result;
    }
    
    public void setSecurityService(SecurityService securityService) {
        this.securityService = securityService;
    }
    
    public void setSettingsService(SettingsService settingsService) {
        this.settingsService = settingsService;
    }
    public void setMediaFileService(MediaFileService mediaFileService) {
        this.mediaFileService = mediaFileService;
    }	
}