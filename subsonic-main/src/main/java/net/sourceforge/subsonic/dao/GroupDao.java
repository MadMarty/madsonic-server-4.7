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
import net.sourceforge.subsonic.dao.GroupDao;
import net.sourceforge.subsonic.domain.Group;
import net.sourceforge.subsonic.domain.InternetRadio;

import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.simple.ParameterizedRowMapper;

/**
 * Provides database services for Access Control.
 *
 * @author Madevil
 */
public class GroupDao extends AbstractDao {


    private static final Logger LOG = Logger.getLogger(GroupDao.class);
    private static final String COLUMNS = "id, name";	
	
    
    private final static RowMapper rowMapper = new GroupMapper();
    
    /**
     * Returns all Groups.
     *
     * @return Possibly empty array of groups.
     */
    public List<Group> getAllGroups() {
        String sql = "select " + COLUMNS + " from user_group";
        return query(sql, rowMapper);
    }

//    public List<Group> getAllGroupsforUser(int userGroupId) {
//
//    	String sql = "select " + COLUMNS + " from user_group";
//        return query(sql, rowMapper);
//    }
    
    public void createGroup(Group group) {
        String sql = "insert into user_group (" + COLUMNS + ") values (null, ?)";
        update(sql, group.getName());
        LOG.info("Created Access Group " + group.getName());
    }    

    public void updateGroup(Group group) {
        String sql = "update user_group set name=? where id=?";
        update(sql, group.getName(), group.getId());
    }    
    
	public void deleteGroup(Group group) {
        String sql = "delete from user_group where id=?";
        update(sql, group.getId());
	}     

	public void resetGroup() {

    update("delete from user_group_access");
    update("insert into user_group_access (user_group_id, music_folder_id, enabled) (select distinct g.id as user_group_id, f.id as music_folder_id, 'true' as enabled from user_group g, music_folder f)");

	}		
	
    private static class GroupMapper implements ParameterizedRowMapper<Group> {
        public Group mapRow(ResultSet rs, int rowNum) throws SQLException {
            return new Group(
                    rs.getInt(1),
                    rs.getString(2));
        }
    }

    
}
