/*
 This file is part of Subsonic.

 Subsonic is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 Subsonic is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with Subsonic.  If not, see <http://www.gnu.org/licenses/>.

 Copyright 2009 (C) Sindre Mehus
 */
package net.sourceforge.subsonic.controller;

import net.sourceforge.subsonic.domain.AccessRight;
import net.sourceforge.subsonic.domain.AccessToken;
import net.sourceforge.subsonic.domain.Group;
import net.sourceforge.subsonic.domain.MusicFolder;
import net.sourceforge.subsonic.service.SecurityService;
import net.sourceforge.subsonic.service.SettingsService;
import org.apache.commons.lang.StringUtils;
import org.jfree.util.Log;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.ParameterizableViewController;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Date;

/**
 * Controller for the page used to administrate the set of internet radio/tv stations.
 *
 * @author Sindre Mehus
 */
public class AccessSettingsController extends ParameterizableViewController {

    private SettingsService settingsService;
    private SecurityService securityService;
    
    @Override
    protected ModelAndView handleRequestInternal(HttpServletRequest request, HttpServletResponse response) throws Exception {

        Map<String, Object> map = new HashMap<String, Object>();

        if (isFormSubmission(request)) {
            String error = handleParameters(request);
            map.put("error", error);
            if (error == null) {
                map.put("reload", true);
				map.put("toast", true);
            }
        }

        ModelAndView result = super.handleRequestInternal(request, response);
        
		List<MusicFolder> allMusicFolders = settingsService.getAllMusicFolders();

        map.put("groups", securityService.GetAllGroups());
        map.put("musicFolders", allMusicFolders);
        map.put("accessGroup", securityService.getAccessGroup());
        map.put("accessToken", securityService.getAllAccessToken());

        result.addObject("model", map);
        return result;
    }

    /**
     * Determine if the given request represents a form submission.
     *
     * @param request current HTTP request
     * @return if the request represents a form submission
     */
    private boolean isFormSubmission(HttpServletRequest request) {
        return "POST".equals(request.getMethod());
    }

    private String handleParameters(HttpServletRequest request) {
    	
    	List<AccessToken> accessToken = securityService.getAllAccessToken();
        
        for (AccessToken Token: accessToken) {
		
            Integer id = Token.getId();
            String name = Token.getName(); 
            
            for (AccessRight AR : Token.getAccessRight()){
            	
//              boolean[] enabled = new boolean[Token.getAccessRight().size()];
              
              boolean EnabledDB = AR.isEnabled();
              int musicFolderIdDB = AR.getMusicfolder_id();
              
          	  boolean Enabled = getParameter(request, "toggle", name, musicFolderIdDB)  != null;
  
          	  if (Enabled != EnabledDB) {
          		  // Update Record
          		  Log.debug("Update AccessRight ");
          		  securityService.updateAccessRight(id, musicFolderIdDB, Enabled);
          	  }
          	  
          	  
//              for (int i = 0; i < Token.getAccessRight().size(); i++) {
//            	  enabled[i] = Enabled; //AR[i]. .getAccessRight(); // .get(i).getId();
//            }
//            	
            	
//            	boolean enabled = getParameter(request, "toggle", name, id)  != null;

//                boolean[] activeEnabled = new boolean[Token.getAccessRight().size()];
    			
//                for (int i = 0; i < Token.getAccessRight().size(); i++) {
//                	activeEnabled[i] = enabled; //AR[i]. .getAccessRight(); // .get(i).getId();
//                }
            }
        }
        return null;
    }

    private String getParameter(HttpServletRequest request, String name, String foldername, Integer id) {
        return StringUtils.trimToNull(request.getParameter(name + "[" + foldername + id + "]"));
    }

    public void setSecurityService(SecurityService securityService) {
        this.securityService = securityService;
    }    
    
    public void setSettingsService(SettingsService settingsService) {
        this.settingsService = settingsService;
    }

}
