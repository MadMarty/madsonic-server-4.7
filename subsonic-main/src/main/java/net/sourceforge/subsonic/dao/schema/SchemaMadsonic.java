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

 Copyright 2012 (C) Madevil
 */
package net.sourceforge.subsonic.dao.schema;

import net.sourceforge.subsonic.Logger;
import org.springframework.jdbc.core.JdbcTemplate;

/**
 * Used for creating and evolving the database schema.
 * This class implements the database schema for Madsonic version 4.7.
 *
 * @author Madevil
 */
public class SchemaMadsonic extends Schema {

    private static final Logger LOG = Logger.getLogger(SchemaMadsonic.class);

    @Override
    public void execute(JdbcTemplate template) {

		////////////////////

        if (template.queryForInt("select count(*) from version where version = 101") == 0) {
            LOG.info("Updating database schema to version 101.");
            template.execute("insert into version values (101)");
			
			// Reset Usersetting: show_now_playing & show_chat
			if (columnExists(template, "show_chat", "user_settings")) {
				template.execute("update user_settings set show_chat = false, show_now_playing = false");
				LOG.info("Database Update 'user_settings.show_chat' was added successfully.");
				LOG.info("Database Update 'user_settings.show_now_playing' was added successfully.");
			}	
        }
		
		////////////////////

		// Add Statistic Table
        if (!tableExists(template, "statistic_user")) {
            LOG.info("Database table 'statistic_user' not found.  Creating it.");
            template.execute("create table statistic_user (" +
                    "id identity," +
                    "username varchar not null," +
                    "media_file_id int not null," +
                    "played datetime not null," +
                    "foreign key (media_file_id) references media_file(id) on delete cascade,"+
                    "foreign key (username) references user(username) on delete cascade)");

            template.execute("create index idx_statistic_user_media_file_id on statistic_user(media_file_id)");
            template.execute("create index idx_statistic_user_username on statistic_user(username)");

            LOG.info("Database table 'statistic_user' was created successfully.");
        }		
            
		////////////////////

		// Add Hot Recommmed Table
		if (!tableExists(template, "hot_rating")) {
			LOG.info("Database table 'hot_rating' not found.  Creating it.");
			template.execute("create table hot_rating (" +
							 "username varchar not null," +
							 "path varchar not null," +
							 "id int not null," +
							 "primary key (username, path)," +
							 "foreign key (username) references user(username) on delete cascade)");
		LOG.info("Database table 'hot_rating' was created successfully.");            
            
        }	
		
        if (template.queryForInt("select count(*) from version where version = 102") == 0) {
            LOG.info("Updating database schema to version 102.");
            template.execute("insert into version values (102)");
			
        if (!columnExists(template, "index", "music_folder")) {
            LOG.info("Database column 'music_folder.index' not found.  Creating it.");
            template.execute("alter table music_folder add index int default 1 not null");
            LOG.info("Database column 'music_folder.index' was added successfully.");
        }			
        }		

		////////////////////
		
        if (template.queryForInt("select count(*) from version where version = 103") == 0) {
            LOG.info("Updating database schema to version 103.");
            template.execute("insert into version values (103)");
            template.execute("create index idx_starred_media_file_media_file_id_username on starred_media_file(media_file_id, username)");
            template.execute("create index idx_starred_media_file_created on starred_media_file(created)");
            LOG.info("Database index 'idx_starred_media_file_media_file_id_username' was added successfully.");
            LOG.info("Database index 'idx_starred_media_file_created' was added successfully.");
        }	
		
		////////////////////
		
        if (template.queryForInt("select count(*) from version where version = 104") == 0) {
            LOG.info("Updating database schema to version 104.");
            template.execute("insert into version values (104)");

			if (template.queryForInt("select count(*) from role where id = 12") == 0) {
				LOG.info("Role 'search' not found in database. Creating it.");
				template.execute("insert into role values (12, 'search')");
				// default for admin/stream role
				template.execute("insert into user_role " +
								 "select distinct u.username, 12 from user u, user_role ur " +
								 "where u.username = ur.username and ur.role_id = 8");
				LOG.info("Role 'search' was created successfully.");
			}
        }        
        ////////////////////
        
        if (template.queryForInt("select count(*) from version where version = 105") == 0) {
            LOG.info("Updating database schema to version 105.");
            template.execute("insert into version values (105)");

			// Added new Usersettings
			if (!columnExists(template, "customscrollbar", "user_settings")) {
				LOG.info("Database column 'user_settings.customscrollbar' not found.  Creating it.");
				template.execute("alter table user_settings add customscrollbar boolean default true not null");
				LOG.info("Database column 'user_settings.customscrollbar' was added successfully.");
			}
        }
        
        ////////////////////

		// Add new User Role 'search' and add as default
        if (template.queryForInt("select count(*) from role where id = 12") == 0) {
            LOG.info("Role 'search' not found in database. Creating it.");
            template.execute("insert into role values (12, 'search')");
			// default for admin/stream role
            template.execute("insert into user_role " +
                             "select distinct u.username, 12 from user u, user_role ur " +
                             "where u.username = ur.username and ur.role_id = 8");
            LOG.info("Role 'search' was created successfully.");
        }

        ////////////////////

		// new transcoding settings
        if (template.queryForInt("select count(*) from version where version = 106") == 0) {
            LOG.info("Updating database schema to version 106.");
            template.execute("insert into version values (106)");

		// wtv transcoding 
	    if (template.queryForInt("select count(*) from transcoding2 where name = 'wtv video'") == 0) {
            template.execute("insert into transcoding2(name, source_formats, target_format, step1) values('wtv video', 'wtv', 'flv', " +
                    "'ffmpeg -ss %o -i %s -async 30 -b %bk -r 23-.976 -s %wx%h -ar 44100 -ac 2 -v 0 -f flv -vcodec libx264 -preset fast -threads 0 -')");		
		}
		// FLAC transcoding
	    if (template.queryForInt("select count(*) from transcoding2 where name = 'FLAC audio'") == 0) {

	    if (template.queryForInt("SELECT count(*) from transcoding2 where source_formats like '%flac%' and name = 'mp3 audio'") == 1) {
			template.execute("update transcoding2 set source_formats = 'ogg oga aac m4a wav wma aif aiff ape mpc shn' " + 
					"where source_formats like '%flac%' and name = 'mp3 audio'");
		}
			template.execute("insert into transcoding2(name, source_formats, target_format, step1, step2) values('FLAC audio', 'flac', 'mp3', " +
					"'ffmpeg -i %s -v 0 -f wav -', 'lame -V 0 --tt %t --ta %a --tl %l -S --resample 44.1 - -')");
		}
		
		// SubWiji transcoding
	    if (template.queryForInt("select count(*) from transcoding2 where name = 'SubWiji'") == 0) {
			template.execute("insert into transcoding2(name, source_formats, target_format, step1, default_active) values('SubWiji', 'mp3', 'mp3', " +
					"'ffmpeg -f mp3 -i %s -ab %bk -v 0 -f mp3 -', false)");
		}
		
    }
        ////////////////////

		// new transcoding settings
        if (template.queryForInt("select count(*) from version where version = 107") == 0) {
            LOG.info("Updating database schema to version 107.");
            template.execute("insert into version values (107)");

		// FLAC transcoding
	    if (template.queryForInt("select count(*) from transcoding2 where name = 'FLAC audio'") == 1) {

		template.execute("delete from transcoding2 where name = 'FLAC audio'");		
		
	    if (template.queryForInt("SELECT count(*) from transcoding2 where source_formats like '%m4a%' and name = 'mp3 audio'") == 1) {
			template.execute("update transcoding2 set source_formats = 'ogg oga aac wav wma aif aiff ape mpc shn' " + 
					"where source_formats like '%m4a%' and name = 'mp3 audio'");
		}

		template.execute("insert into transcoding2(name, source_formats, target_format, step1, step2) values('m4a/FLAC audio', 'flac m4a', 'mp3', " +
					"'ffmpeg -i %s -v 0 -f wav -', 'lame -V 0 --tt %t --ta %a --tl %l -S --resample 44.1 - -')");
		}
		
		LOG.info("new transcoding in table 'transcoding2' was inserted successfully.");
      }
	  
        ////////////////////
		
		// new transcoding settings
        if (template.queryForInt("select count(*) from version where version = 108") == 0) {
            LOG.info("Updating database schema to version 108.");
            template.execute("insert into version values (108)");

		// FLAC transcoding
	    if (template.queryForInt("select count(*) from transcoding2 where name = 'm4a/FLAC audio'") == 1) {

		template.execute("delete from transcoding2 where name = 'm4a/FLAC audio'");		
		
		template.execute("insert into transcoding2(name, source_formats, target_format, step1 ) values('m4a/FLAC audio', 'm4a flac', 'mp3', " +
					"'Audioffmpeg -i %s -ab 256k -ar 44100 -ac 2 -v 0 -f mp3 -')");
					
		template.execute("update transcoding2 set step1 = 'Audioffmpeg -i %s -ab %bk -v 0 -f mp3 -' where name = 'mp3 audio'");					
		template.execute("update transcoding2 set step1 = 'Audioffmpeg -f mp3 -i %s -ab %bk -v 0 -f mp3 -' where name = 'SubWiji'");					
					
		}
		
		LOG.info("new transcoding in table 'transcoding2' was inserted successfully.");
      }

		// Cleanup Transcoding
        if (template.queryForInt("select count(*) from version where version = 109") == 0) {
            LOG.info("Updating database schema to version 109.");
//            template.execute("insert into version values (109)");
		}
	  

		////////////////////

		// new Access Control
        if (template.queryForInt("select count(*) from version where version = 110") == 0) {
            LOG.info("Updating database schema to version 110.");
            template.execute("insert into version values (110)");
		
			// Add Group Table
			if (!tableExists(template, "user_group")) {
				LOG.info("Database table 'user_group' not found.  Creating it.");
				template.execute("create table user_group (" +
						"id identity, " +
						"name varchar not null, " +
						"primary key (id))");
				LOG.info("Database table 'user_group' was created successfully.");
			}	

			// Add Group Access Table
			if (!tableExists(template, "user_group_access")) {
				LOG.info("Database table 'user_group_access' not found.  Creating it.");
				template.execute("create table user_group_access (" +
								 "user_group_id integer not null, " +
								 "music_folder_id integer not null, " +
								 "enabled boolean default true not null, " + 
								 "primary key (user_group_id, music_folder_id)," +
								 "foreign key (user_group_id) references user_group(id) on delete cascade," +
								 "foreign key (music_folder_id) references music_folder(id) on delete cascade)");
			LOG.info("Database table 'user_group_access' was created successfully.");            

            template.execute("create index idx_user_group_access_user_group_id_music_folder_id_enabled on user_group_access(user_group_id, music_folder_id, enabled)");
            LOG.info("Database index 'idx_user_group_access_user_group_id_music_folder_id_enabled' was added successfully.");
			}	
		}


		////////////////////
		
		// new transcoding settings
        if (template.queryForInt("select count(*) from version where version = 111") == 0) {
            
			LOG.info("Updating database schema to version 111.");
            template.execute("insert into version values (111)");
			
			//ALTER TABLE USER drop constraint FK_2
			//ALTER TABLE USER drop group_id

			template.execute("alter table user add column group_id integer default 0 not null;");

			template.execute("insert into user_group (id, name) values (0, 'ALL')");
			template.execute("insert into user_group (id, name) values (1, 'GUEST')");
			template.execute("insert into user_group (id, name) values (2, 'FAMILY')");
			template.execute("insert into user_group (id, name) values (3, 'FRIENDS')");
			template.execute("insert into user_group (id, name) values (4, 'LIMITED')");
			
			// Insert Default Access to admin

			// template.execute("insert into public.user_group_access (user_group_id, music_folder_id) values (0, 0)");

			// Insert Default Access to all
			
			template.execute("insert into user_group_access (user_group_id, music_folder_id, enabled) " +
							"(select distinct g.id as user_group_id, f.id as music_folder_id, 'true' as enabled from user_group g, music_folder f)");
						
			template.execute("alter table user add constraint fk_group_id foreign key (group_id) references user_group (id)");
			
			LOG.info("Database table 'user' was updated successfully.");            
		}

		// Reset Access to default
        if (template.queryForInt("select count(*) from version where version = 112") == 0) {
            
			LOG.info("Updating database schema to version 112.");
            template.execute("insert into version values (112)");

            template.execute("delete from user_group_access");
			template.execute("insert into user_group_access (user_group_id, music_folder_id, enabled) " +
							"(select distinct g.id as user_group_id, f.id as music_folder_id, 'true' as enabled from user_group g, music_folder f)");
		}	
  }
}