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
package net.sourceforge.subsonic.dao;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import net.sourceforge.subsonic.Logger;
import net.sourceforge.subsonic.dao.AccessRightDao;
import net.sourceforge.subsonic.domain.AccessGroup;
import net.sourceforge.subsonic.domain.AccessRight;
import net.sourceforge.subsonic.domain.AccessToken;
import net.sourceforge.subsonic.domain.Album;
import net.sourceforge.subsonic.domain.Group;

import org.apache.commons.lang.ObjectUtils;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.simple.ParameterizedRowMapper;

/**
 * Provides database services for Access Control.
 *
 * @author Madevil
 */
public class AccessRightDao extends AbstractDao {

	private static final String COLUMNS = "music_folder_id, enabled";	
	
    private final RowMapper rowMapper = new AccessRightMapper();
    private static final Logger LOG = Logger.getLogger(AccessRightDao.class);
    
    
    public AccessGroup getAllAccessToken(List<Group> allGroup){
    	
    	AccessGroup AG = new AccessGroup();
    	
    	for (Group group : allGroup) {
    		AG.addAccessToken(getAccessTokenByGroup(group));
    	}
		return AG;
    }
    
    
	public AccessToken getAccessTokenByGroup(Group userGroup) {
		
		AccessToken AT = new AccessToken();
	    List<AccessRight> ARList = query("select " + COLUMNS + " from user_group_access where user_group_id= ? ", rowMapper, userGroup.getId());

	    if (ARList.isEmpty()) {
	        return null;
	    }		
	    for (AccessRight AR : ARList) {
	    //	if (AR.isEnabled() == true) {
		    	AT.addAccessRight(AR);
		    	AT.addAccessRight2(AR);
		    	
	    //	}
	    }
	    AT.setUserGroupId(userGroup.getId());
	    AT.setUserGroupName(userGroup.getName());
	    
		return AT;
	}		
	
	public void updateAccessRight(int user_group_id, int music_folder_id, boolean isEnabled) {
        String sql = "update user_group_access set Enabled=? where user_group_id=? and music_folder_id=?";
        update(sql, isEnabled, user_group_id, music_folder_id);
	}
	
	
    private static class AccessRightMapper implements ParameterizedRowMapper<AccessRight> {
        public AccessRight mapRow(ResultSet rs, int rowNum) throws SQLException {
            return new AccessRight(	rs.getInt(1), rs.getBoolean(2));
        }
    }	
	
}
