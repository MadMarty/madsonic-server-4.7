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

import net.sourceforge.subsonic.dao.AlbumDao;
import net.sourceforge.subsonic.dao.ArtistDao;
import net.sourceforge.subsonic.dao.MediaFileDao;
import net.sourceforge.subsonic.service.MediaScannerService;
import net.sourceforge.subsonic.service.SecurityService;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.ParameterizableViewController;
import org.springframework.web.servlet.view.RedirectView;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.HashMap;
import java.util.Map;

/**
 * Controller for the page used to administrate the set of internet radio/tv stations.
 *
 * @author Sindre Mehus
 */
public class CleanupSettingsController extends ParameterizableViewController {

    private SecurityService securityService;
    private MediaScannerService mediaScannerService;
    private ArtistDao artistDao;
    private AlbumDao albumDao;
    private MediaFileDao mediaFolderDao;
    
    @Override
    protected ModelAndView handleRequestInternal(HttpServletRequest request, HttpServletResponse response) throws Exception {

        Map<String, Object> map = new HashMap<String, Object>();

        if (request.getParameter("FullscanNow") != null) {
         //   mediaScannerService.scanLibrary();
			map.put("done", true);
        }		
		
        if (request.getParameter("scanNow") != null) {
            mediaScannerService.scanLibrary();
			map.put("done", true);
        }

        if (request.getParameter("expunge") != null) {
            expunge();
			map.put("done", true);
        }		
		
        if (request.getParameter("resetControl") != null) {
            securityService.resetControl();
			map.put("done", true);
            }		

        ModelAndView result = super.handleRequestInternal(request, response);
        
        result.addObject("model", map);
        return result;
    }

    private void expunge() {
        artistDao.expunge();
        albumDao.expunge();
        mediaFolderDao.expunge();
    }	
	
    public void setSecurityService(SecurityService securityService) {
        this.securityService = securityService;
    }    
 
     public void setMediaScannerService(MediaScannerService mediaScannerService) {
        this.mediaScannerService = mediaScannerService;
    }

    public void setArtistDao(ArtistDao artistDao) {
        this.artistDao = artistDao;
    }

    public void setAlbumDao(AlbumDao albumDao) {
        this.albumDao = albumDao;
    }

    public void setMediaFolderDao(MediaFileDao mediaFolderDao) {
        this.mediaFolderDao = mediaFolderDao;
    }
}
